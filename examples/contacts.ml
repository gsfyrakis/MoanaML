(*
* Copyright (c) 2015 Yan Shvartzshnaider
*
* Permission to use, copy, modify, and distribute this software for any
* purpose with or without fee is hereby granted, provided that the above
* copyright notice and this permission notice appear in all copies.
*
* THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
* WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
* ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
* WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
* ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
* OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*)
(*** This is an implementation of a sample application - contacts

The main functionality:

* Add contact info
* Query info on the contact
***)
open Config
  
let jon =
  Helper.to_tuple_lst
    "{(a,fn,Jon,contacts)
	  (a,last,Crowcroft,contacts)    
   (a,email,jon.crowcroft@cl.cam.ac.uk,contacts)
	 (a,twitter,@tforcworc,contacts)
	 (a,mobile, 617-000-0001,contacts)
   (a,title,Professor,contacts)	
	 (a,image,jon.jpg, contacts)
	 (a,knows,c,contacts)
	 (a,knows,d,contacts)
	 (a,knows,e,contacts)
	}"
  
let amir =
  Helper.to_tuple_lst
    "{(b,fn,Amir,contacts) 
		(b,last,Chaudhry,contacts)    
   (b,email,amir.chaudhry@cl.cam.ac.uk,contacts)
	 (b,twitter,@amirmc,contacts)
	 (b,image,amir.jpg, contacts)
   (b,title,Postdoc,contacts)
   (b,knows,a,contacts)
   (b,knows,c,contacts)
	 (b,knows,d,contacts)
	}"
  
let anil =
  Helper.to_tuple_lst
    "{(c,fn,Anil,contacts) 
	  (c,last,Madhavapeddy, contacts)
   (c,email,anil@recoil.org,contacts)    
	 (c,image,anil.jpg, contacts)
	 (c,twitter,@avsm,contacts) 
	 (c,email,anil.madhavapeddy@recoil.org,contacts)
   (c,title,Lecturer,contacts)}"
  
let carlos =
  Helper.to_tuple_lst
    "{(d,fn,Carlos,contacts) 
	 (d,last,Molina-jimenez, contacts)
	 (d,image,carlos.jpg, contacts)    
   (d,email,cm770@cam.ac.uk,contacts)        
   (d,title,Postdoc,contacts)
	 (d,twitter,@carlos,contacts) 
	 (d,knows,a,contacts)
	 (d,knows,c,contacts)}"
  
let richard =
  Helper.to_tuple_lst
    "{(e,fn,Richard,contacts)    
		(e,last,Mortier,contacts)
   (e,email,richard.mortier@nottingham.ac.uk,contacts)
	 (e,image,mort.png, contacts)
	 (e,twitter,@mort__,contacts)        
   (e,title,Lecturer,contacts)
	 (e,knows,c,contacts)
	 (e,knows,d,contacts)
	}"
  
let policies =
  Helper.to_tuple_lst "{
	(b,canView,a,policies)
	(c,canView,d,policies)	
	}"
  
let contacts = [ jon; amir; anil; carlos; richard ]
  
(*let contacts = Helper.tuples_from_file "contacts.db"*)
(* sample query *)
let q2 =
"MAP {
?y,fn,Carlos,contacts
?y,last,?last,contacts
?y,email,?email,contacts
?y,image,?image,contacts
?y,twitter,?twitter,contacts
}"

  
(* execute policy to bring all the tuples that b can view *)
let q1 =
"MAP {
?y, canView,?x, policies
?x, ?anypred, ?anyobj, contacts
}"
  

(* let prnt = Helper.print_tuples_list contacts*)
  
let results = (ReteImpl.InMemory.exec_qry q1 (List.flatten (contacts @ [policies]))) |> (ReteImpl.InMemory.exec_bm q2)


let (ReteImpl.InMemory.Node (_, BM res_bm, _)) = results
  
let p2 =
  Helper.print_tuples (Helper.TupleSet.elements (ReteImpl.InMemory.get_tuples results))

(*let p = ReteImpl.InMemory.print_bm res_bm*)

let r_map = ReteImpl.InMemory.get_res_map results [ "?y"; "?fn"; "?last"; "?email"; "?image"; "?mobile"; "?twitter"]
  
let _ = Helper.StringMap.iter Helper.print_var r_map 
  
 (********* Testing unified Moana graph signature ****)
let _ = print_string "---------------GRAPH signature----------------\n"
let q2_ = Helper.str_query_list
  "MAP {
	?y,fn,?name,contacts
	?y,email,?email,contacts
	}"
  
(* execute policy to bring all the tuples that b can view *)
let q1_ = Helper.str_query_list
  "MAP {
	 ?x, knows, ?o, contacts
	 ?o, email, ?email, contacts	 
	 ?o, fn, ?n, contacts
	}"
  


(*let contact_and_policies_graph = Moana_rete.G.init (List.flatten (contacts @ [policies])) 

let result = Moana_rete.G.map contact_and_policies_graph  ~tuples:q2_*)

module G = Moana.Make(Moana_rete.S) 

let graph = G.init (List.flatten (contacts @ [policies])) |>  G.map  ~tuples:q1_ |> G.map ~tuples:q2_

let _ = Helper.print_tuples (G.to_list graph)