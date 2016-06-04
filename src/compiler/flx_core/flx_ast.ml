module CS = Flx_code_spec

(** {6 Source Reference}
 *
 * Provides a reference to the original source.  *)

(** {6 Abstract Syntax Tree}
 *
 * AST types are nodes of the Abstract Syntax Tree generated by the parser. *)

type index_t = int
type index_map_t = (int,int) Hashtbl.t

type base_type_qual_t = [
  | `Incomplete
  | `Uncopyable
  | `Pod
  | `GC_pointer (* this means the type is a pointer the GC must follow *)
]

(** type of a qualified name *)
type qualified_name_t =
  [
  | `AST_void of Flx_srcref.t
  | `AST_name of Flx_srcref.t * Flx_id.t * typecode_t list
  | `AST_case_tag of Flx_srcref.t * int
  | `AST_typed_case of Flx_srcref.t * int * typecode_t
  | `AST_lookup of Flx_srcref.t * (expr_t * Flx_id.t * typecode_t list)
  | `AST_index of Flx_srcref.t * string * index_t
  | `AST_callback of Flx_srcref.t * qualified_name_t
  ]

(** type of a suffixed name *)
and suffixed_name_t =
  [
  | `AST_void of Flx_srcref.t
  | `AST_name of Flx_srcref.t * Flx_id.t * typecode_t list
  | `AST_case_tag of Flx_srcref.t * int
  | `AST_typed_case of Flx_srcref.t * int * typecode_t
  | `AST_lookup of Flx_srcref.t * (expr_t * Flx_id.t * typecode_t list)
  | `AST_index of Flx_srcref.t * string * index_t
  | `AST_callback of Flx_srcref.t * qualified_name_t
  | `AST_suffix of Flx_srcref.t * (qualified_name_t * typecode_t)
  ]

(** {7 Type sublanguage}
 *
 * The encoding '`TYP_void' is the categorical initial: the type of an empty
 * union, and the type ordinary procedure types return.  There are no values
 * of this type. *)

(** type of a type *)
and typecode_t =
  | TYP_label 
  | TYP_void of Flx_srcref.t                   (** void type *)
  | TYP_name of Flx_srcref.t * Flx_id.t * typecode_t list
  | TYP_case_tag of Flx_srcref.t * int
  | TYP_typed_case of Flx_srcref.t * int * typecode_t
  | TYP_lookup of Flx_srcref.t * (expr_t * Flx_id.t * typecode_t list)
  | TYP_index of Flx_srcref.t * string * index_t
  | TYP_callback of Flx_srcref.t * qualified_name_t
  | TYP_suffix of Flx_srcref.t * (qualified_name_t * typecode_t)
  | TYP_patvar of Flx_srcref.t * Flx_id.t
  | TYP_patany of Flx_srcref.t
  | TYP_tuple of typecode_t list               (** product type *)
  | TYP_unitsum of int                         (** sum of units  *)
  | TYP_sum of typecode_t list                 (** numbered sum type *)
  | TYP_intersect of typecode_t list           (** intersection type *)
  | TYP_record of (Flx_id.t * typecode_t) list
  | TYP_polyrecord of (Flx_id.t * typecode_t) list * typecode_t
  | TYP_variant of (Flx_id.t * typecode_t) list (** anon sum *)
  | TYP_function of typecode_t * typecode_t    (** function type *)
  | TYP_cfunction of typecode_t * typecode_t   (** C function type *)
  | TYP_pointer of typecode_t                  (** pointer type *)
  | TYP_array of typecode_t * typecode_t       (** array type base ^ index *)
  | TYP_as of typecode_t * Flx_id.t            (** fixpoint *)
  | TYP_typeof of expr_t                       (** typeof *)
  | TYP_var of index_t                         (** unknown type *)
  | TYP_none                                   (** unspecified *)
  | TYP_ellipsis                               (** ... for varargs *)
(*  | TYP_lvalue of typecode_t *)                  (** ... lvalue annotation *)
  | TYP_isin of typecode_t * typecode_t        (** typeset membership *)

  | TYP_defer of Flx_srcref.t * typecode_t option ref


  (* sets of types *)
  | TYP_typeset of typecode_t list             (** discrete set of types *)
  | TYP_setunion of typecode_t list            (** union of typesets *)
  | TYP_setintersection of typecode_t list     (** intersection of typesets *)

  (* dualizer *)
  | TYP_dual of typecode_t                     (** dual *)

  | TYP_apply of typecode_t * typecode_t       (** type function application *)
  | TYP_typefun of simple_parameter_t list * typecode_t * typecode_t
                                                (** type lambda *)
  | TYP_type                                   (** meta type of a type *)
  | TYP_type_tuple of typecode_t list          (** meta type product *)

  | TYP_type_match of typecode_t * (typecode_t * typecode_t) list
  | TYP_type_extension of Flx_srcref.t * typecode_t list * typecode_t
  | TYP_tuple_cons of Flx_srcref.t * typecode_t * typecode_t

and raw_typeclass_insts_t = qualified_name_t list
and vs_aux_t = {
  raw_type_constraint:typecode_t;
  raw_typeclass_reqs: raw_typeclass_insts_t
}

and plain_vs_list_t = (Flx_id.t * typecode_t) list
and vs_list_t = plain_vs_list_t * vs_aux_t

and axiom_kind_t = Axiom | Lemma
and axiom_method_t = Predicate of expr_t | Equation of expr_t * expr_t

(** {7 Expressions}
 *
 * Raw expression terms. *)
and expr_t =
  | EXPR_label of Flx_srcref.t * string
  | EXPR_vsprintf of Flx_srcref.t * string
  | EXPR_interpolate of Flx_srcref.t * string
  | EXPR_map of Flx_srcref.t * expr_t * expr_t
  | EXPR_noexpand of Flx_srcref.t * expr_t
  | EXPR_name of Flx_srcref.t * Flx_id.t * typecode_t list
  | EXPR_index of Flx_srcref.t * string * index_t
  | EXPR_case_tag of Flx_srcref.t * int
  | EXPR_typed_case of Flx_srcref.t * int * typecode_t
  | EXPR_projection of Flx_srcref.t * int * typecode_t
  | EXPR_rnprj of Flx_srcref.t * string * int * expr_t
  | EXPR_lookup of Flx_srcref.t * (expr_t * Flx_id.t * typecode_t list)
  | EXPR_apply of Flx_srcref.t * (expr_t * expr_t)
  | EXPR_tuple of Flx_srcref.t * expr_t list
  | EXPR_tuple_cons of Flx_srcref.t * expr_t * expr_t
  | EXPR_record of Flx_srcref.t * (Flx_id.t * expr_t) list
  | EXPR_record_type of Flx_srcref.t * (Flx_id.t * typecode_t) list
  | EXPR_polyrecord of Flx_srcref.t * (Flx_id.t * expr_t) list * expr_t
  | EXPR_remove_fields of Flx_srcref.t * expr_t * string list
  | EXPR_polyrecord_type of Flx_srcref.t * (Flx_id.t * typecode_t) list * typecode_t
  | EXPR_variant of Flx_srcref.t * (Flx_id.t * expr_t)
  | EXPR_variant_type of Flx_srcref.t * (Flx_id.t * typecode_t) list
  | EXPR_arrayof of Flx_srcref.t * expr_t list
  | EXPR_coercion of Flx_srcref.t * (expr_t * typecode_t)
  | EXPR_suffix of Flx_srcref.t * (qualified_name_t * typecode_t)
  | EXPR_patvar of Flx_srcref.t * Flx_id.t
  | EXPR_patany of Flx_srcref.t
  | EXPR_void of Flx_srcref.t
  | EXPR_ellipsis of Flx_srcref.t
  | EXPR_product of Flx_srcref.t * expr_t list
  | EXPR_sum of Flx_srcref.t * expr_t list
  | EXPR_intersect of Flx_srcref.t * expr_t list
  | EXPR_isin of Flx_srcref.t * (expr_t * expr_t)
  | EXPR_orlist of Flx_srcref.t * expr_t list
  | EXPR_andlist of Flx_srcref.t * expr_t list
  | EXPR_arrow of Flx_srcref.t * (expr_t * expr_t)
  | EXPR_longarrow of Flx_srcref.t * (expr_t * expr_t)
  | EXPR_superscript of Flx_srcref.t * (expr_t * expr_t)
  | EXPR_literal of Flx_srcref.t * Flx_literal.literal_t
  | EXPR_deref of Flx_srcref.t * expr_t
  | EXPR_ref of Flx_srcref.t * expr_t
  | EXPR_likely of Flx_srcref.t * expr_t
  | EXPR_unlikely of Flx_srcref.t * expr_t
  | EXPR_new of Flx_srcref.t * expr_t
  | EXPR_callback of Flx_srcref.t * qualified_name_t
  | EXPR_lambda of Flx_srcref.t * (funkind_t * vs_list_t * params_t list * typecode_t * statement_t list)
  | EXPR_range_check of Flx_srcref.t * expr_t * expr_t * expr_t
  | EXPR_not of Flx_srcref.t * expr_t

  (* this boolean expression checks its argument is
     the nominated union variant .. not a very good name for it
  *)
  | EXPR_match_ctor of Flx_srcref.t * (qualified_name_t * expr_t)

  | EXPR_match_variant of Flx_srcref.t * (string * expr_t)

  (* this boolean expression checks its argument is the nominate
     sum variant
  *)
  | EXPR_match_case of Flx_srcref.t * (int * expr_t)

  (* this extracts the argument of a named union variant -- unsafe *)
  | EXPR_ctor_arg of Flx_srcref.t * (qualified_name_t * expr_t)

  | EXPR_variant_arg of Flx_srcref.t * (string * expr_t)

  (* this extracts the argument of a number sum variant -- unsafe *)
  | EXPR_case_arg of Flx_srcref.t * (int * expr_t)

  (* this just returns an integer equal to union or sum index *)
  | EXPR_case_index of Flx_srcref.t * expr_t (* the zero origin variant index *)

  | EXPR_letin of Flx_srcref.t * (pattern_t * expr_t * expr_t)

  | EXPR_get_n of Flx_srcref.t * (int * expr_t)
  | EXPR_get_named_variable of Flx_srcref.t * (Flx_id.t * expr_t)
  | EXPR_as of Flx_srcref.t * (expr_t * Flx_id.t)
  | EXPR_as_var of Flx_srcref.t * (expr_t * Flx_id.t)
  | EXPR_match of Flx_srcref.t * (expr_t * (pattern_t * expr_t) list)

  (* this extracts the tail of a tuple *)
  | EXPR_get_tuple_tail of Flx_srcref.t * expr_t
  | EXPR_get_tuple_head of Flx_srcref.t * expr_t

  | EXPR_typeof of Flx_srcref.t * expr_t
  | EXPR_cond of Flx_srcref.t * (expr_t * expr_t * expr_t)

  | EXPR_expr of Flx_srcref.t * Flx_code_spec.t * typecode_t * expr_t

  | EXPR_type_match of Flx_srcref.t * (typecode_t * (typecode_t * typecode_t) list)
  | EXPR_typecase_match of Flx_srcref.t * (expr_t * (typecode_t * expr_t) list)

  | EXPR_extension of Flx_srcref.t * expr_t list * expr_t

(** {7 Patterns}
 *
 * Patterns; used for matching variants in match statements. *)
and pattern_t =
  | PAT_none of Flx_srcref.t

  (* constants *)
  | PAT_literal of Flx_srcref.t * Flx_literal.literal_t

  (* ranges *)
  | PAT_range of Flx_srcref.t * Flx_literal.literal_t * Flx_literal.literal_t

  (* other *)
  | PAT_coercion of Flx_srcref.t * pattern_t * typecode_t

  | PAT_name of Flx_srcref.t * Flx_id.t
  | PAT_tuple of Flx_srcref.t * pattern_t list
  | PAT_tuple_cons of Flx_srcref.t * pattern_t * pattern_t
  | PAT_any of Flx_srcref.t
  | PAT_setform_any of Flx_srcref.t
    (* second list is group bindings 1 .. n-1: EXCLUDES 0 cause we can use 'as' for that ?? *)
  | PAT_const_ctor of Flx_srcref.t * qualified_name_t
  | PAT_nonconst_ctor of Flx_srcref.t * qualified_name_t * pattern_t

  | PAT_const_variant of Flx_srcref.t * string 
  | PAT_nonconst_variant of Flx_srcref.t * string * pattern_t

  | PAT_as of Flx_srcref.t * pattern_t * Flx_id.t
  | PAT_when of Flx_srcref.t * pattern_t * expr_t
  | PAT_record of Flx_srcref.t * (Flx_id.t * pattern_t) list
  | PAT_polyrecord of Flx_srcref.t * (Flx_id.t * pattern_t) list * Flx_id.t

  | PAT_expr of Flx_srcref.t * expr_t

(** {7 Statements}
 *
 * Statements; that is, the procedural sequence control system. *)
and param_kind_t = [`PVal | `PVar ]
and simple_parameter_t = Flx_id.t * typecode_t
and parameter_t = param_kind_t * Flx_id.t * typecode_t * expr_t option
and lvalue_t = [
  | `Val of Flx_srcref.t * Flx_id.t
  | `Var of Flx_srcref.t * Flx_id.t
  | `Name of Flx_srcref.t * Flx_id.t
  | `Skip of Flx_srcref.t
  | `List of tlvalue_t list
  | `Expr of Flx_srcref.t * expr_t
]
and tlvalue_t = lvalue_t * typecode_t option

and funkind_t = [
  | `Function
  | `CFunction
  | `GeneratedInlineProcedure
  | `GeneratedInlineFunction
  | `InlineFunction
  | `NoInlineFunction
  | `Virtual
  | `Ctor
  | `Generator
  | `GeneratorMethod
  | `Method
  | `Object
]

and property_t = [
  | `Recursive
  | `Inline
  | `GeneratedInline
  | `NoInline
  | `Inlining_started
  | `Inlining_complete
  | `Generated of string
  | `Heap_closure        (* a heaped closure is formed *)
  | `Explicit_closure    (* explicit closure expression *)
  | `Stackable           (* closure can be created on stack *)
  | `Stack_closure       (* a stacked closure is formed *)
  | `Unstackable         (* closure cannot be created on stack *)
  | `Pure
  | `Strict
  | `NonStrict
  | `ImPure
  | `Total 
  | `Partial
  | `Uses_global_var     (* a global variable is explicitly used *)
  | `Ctor                (* Class constructor procedure *)
  | `Generator           (* Generator: fun with internal state *)
  | `Yields              (* Yielding generator *)
  | `Cfun                (* C function *)
  | `Lvalue              (* primitive returns lvalue *)

  (* one of the below must be set before code generation *)
  | `Requires_ptf        (* a pointer to thread frame is needed *)
  | `Not_requires_ptf    (* no pointer to thread frame is needed *)

  | `Uses_gc             (* requires gc locally *)
  | `Virtual             (* interface in a typeclass *)
  | `Tag of string       (* whatever *)
  | `Export
  | `NamedExport of string
]

and type_qual_t = [
  | base_type_qual_t
  | `Raw_needs_shape of typecode_t
  | `Scanner of CS.t
  | `Finaliser of CS.t
  | `Encoder of CS.t
  | `Decoder of CS.t
]

and requirement_t =
  | Body_req of CS.t
  | Header_req of CS.t
  | Named_req of qualified_name_t
  | Property_req of string
  | Package_req of CS.t
  | Scanner_req of CS.t
  | Finaliser_req of CS.t
  | Encoder_req of CS.t
  | Decoder_req of CS.t

and ikind_t = [
  | `Header
  | `Body
  | `Package
]

and raw_req_expr_t =
  | RREQ_atom of requirement_t
  | RREQ_or of raw_req_expr_t * raw_req_expr_t
  | RREQ_and of raw_req_expr_t * raw_req_expr_t
  | RREQ_true
  | RREQ_false

and named_req_expr_t =
  | NREQ_atom of qualified_name_t
  | NREQ_or of named_req_expr_t * named_req_expr_t
  | NREQ_and of named_req_expr_t * named_req_expr_t
  | NREQ_true
  | NREQ_false

and prec_t = string
and params_t = parameter_t list * expr_t option (* second arg is a constraint *)

and ast_term_t =
  | Expression_term of expr_t
  | Statement_term of statement_t
  | Statements_term of statement_t list
  | Identifier_term of string
  | Keyword_term of string
  | Apply_term of ast_term_t * ast_term_t list

and statement_t =
  | STMT_type_error of Flx_srcref.t * statement_t
  | STMT_cgoto of Flx_srcref.t * expr_t
  | STMT_try of Flx_srcref.t 
  | STMT_endtry of Flx_srcref.t 
  | STMT_catch of Flx_srcref.t  * Flx_id.t * typecode_t
  | STMT_include of Flx_srcref.t * string
  | STMT_open of Flx_srcref.t * vs_list_t * qualified_name_t

  (* the keyword for this one is 'inherit' *)
  | STMT_inject_module of Flx_srcref.t * vs_list_t * qualified_name_t
  | STMT_use of Flx_srcref.t * Flx_id.t * qualified_name_t
  | STMT_comment of Flx_srcref.t * string (* for documenting generated code *)
  (*
  | STMT_public of Flx_srcref.t * string * statement_t
  *)
  | STMT_private of Flx_srcref.t * statement_t

  (* definitions *)
  | STMT_reduce of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      simple_parameter_t list *
      expr_t *
      expr_t
  | STMT_axiom of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      params_t *
      axiom_method_t
  | STMT_lemma of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      params_t *
      axiom_method_t
  | STMT_function of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      params_t *
      (typecode_t * expr_t option) *
      property_t list *
      statement_t list
  | STMT_curry of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      params_t list *
      (typecode_t * expr_t option) *
      funkind_t *
      property_t list *
      statement_t list

  (* macros *)
  | STMT_macro_val of Flx_srcref.t * Flx_id.t list * expr_t

  (* type macros *)
  | STMT_macro_forall of
      Flx_srcref.t *
      Flx_id.t list *
      expr_t *
      statement_t list

  (* composition of statements: note NOT A BLOCK *)
  | STMT_seq of Flx_srcref.t * statement_t list

  (* types *)
  | STMT_union of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      (Flx_id.t * int option * vs_list_t * typecode_t) list
  | STMT_struct of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      (Flx_id.t * typecode_t) list
  | STMT_cstruct of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      (Flx_id.t * typecode_t) list *
      raw_req_expr_t
  | STMT_type_alias of Flx_srcref.t * Flx_id.t * vs_list_t * typecode_t
  | STMT_inherit of Flx_srcref.t * Flx_id.t * vs_list_t * qualified_name_t
  | STMT_inherit_fun of Flx_srcref.t * Flx_id.t * vs_list_t * qualified_name_t

  (* variables *)
  | STMT_val_decl of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      typecode_t option *
      expr_t option

  | STMT_lazy_decl of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      typecode_t option *
      expr_t option

  | STMT_var_decl of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      typecode_t option *
      expr_t option

  | STMT_ref_decl of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      typecode_t option *
      expr_t option

  (* module system *)
  | STMT_untyped_module of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      statement_t list

  | STMT_typeclass of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      statement_t list

  | STMT_instance of
      Flx_srcref.t *
      vs_list_t *
      qualified_name_t *
      statement_t list

  (* control structures: primitives *)
  | STMT_label of Flx_srcref.t * Flx_id.t
  (*
  | STMT_whilst of Flx_srcref.t * expr_t * statement_t list
  | STMT_until of Flx_srcref.t * expr_t * statement_t list
  *)
  | STMT_goto of Flx_srcref.t * Flx_id.t
  | STMT_ifgoto of Flx_srcref.t * expr_t *Flx_id.t
  | STMT_ifreturn of Flx_srcref.t * expr_t
  | STMT_invariant of Flx_srcref.t * expr_t
  | STMT_ifdo of Flx_srcref.t * expr_t * statement_t list * statement_t list
  | STMT_call of Flx_srcref.t * expr_t * expr_t
  | STMT_assign of Flx_srcref.t * Flx_id.t * tlvalue_t * expr_t
  | STMT_cassign of Flx_srcref.t * expr_t * expr_t
  | STMT_jump of Flx_srcref.t * expr_t * expr_t
  | STMT_loop of Flx_srcref.t * Flx_id.t * expr_t
  | STMT_svc of Flx_srcref.t * Flx_id.t
  | STMT_fun_return of Flx_srcref.t * expr_t
  | STMT_yield of Flx_srcref.t * expr_t
  | STMT_proc_return of Flx_srcref.t
  | STMT_proc_return_from of Flx_srcref.t * string
  | STMT_halt of Flx_srcref.t  * string
  | STMT_trace of Flx_srcref.t  * Flx_id.t * string
  | STMT_nop of Flx_srcref.t * string
  | STMT_assert of Flx_srcref.t * expr_t
  | STMT_init of Flx_srcref.t * Flx_id.t * expr_t
  | STMT_stmt_match of Flx_srcref.t * (expr_t * (pattern_t * statement_t list) list)

  | STMT_newtype of Flx_srcref.t * Flx_id.t * vs_list_t * typecode_t
  | STMT_export_requirement of Flx_srcref.t * raw_req_expr_t

  (* binding structures [prolog] *)
  | STMT_abs_decl of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      type_qual_t list *
      Flx_code_spec.t *
      raw_req_expr_t

  | STMT_ctypes of
      Flx_srcref.t *
      (Flx_srcref.t * Flx_id.t) list *
      type_qual_t list *
      raw_req_expr_t

  | STMT_const_decl of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      typecode_t *
      Flx_code_spec.t *
      raw_req_expr_t

  | STMT_fun_decl of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      typecode_t list *
      typecode_t *
      Flx_code_spec.t *
      raw_req_expr_t *
      prec_t

  | STMT_callback_decl of
      Flx_srcref.t *
      Flx_id.t *
      typecode_t list *
      typecode_t *
      raw_req_expr_t

  (* embedding *)
  | STMT_insert of
      Flx_srcref.t *
      Flx_id.t *
      vs_list_t *
      Flx_code_spec.t *
      ikind_t *
      raw_req_expr_t
  | STMT_code of Flx_srcref.t * Flx_code_spec.t * expr_t

  | STMT_noreturn_code of Flx_srcref.t * Flx_code_spec.t * expr_t

  | STMT_export_fun of Flx_srcref.t * suffixed_name_t * string
  | STMT_export_cfun of Flx_srcref.t * suffixed_name_t * string
  | STMT_export_python_fun of Flx_srcref.t * suffixed_name_t * string
  | STMT_export_type of Flx_srcref.t * typecode_t * string
  | STMT_export_struct of Flx_srcref.t * string
  | STMT_export_union of Flx_srcref.t * suffixed_name_t * string

  | STMT_scheme_string of Flx_srcref.t * string

type exe_t =
  | EXE_type_error of exe_t
  | EXE_code of CS.t * expr_t (* for inline C++ code *)
  | EXE_noreturn_code of CS.t * expr_t  (* for inline C++ code *)
  | EXE_comment of string (* for documenting generated code *)
  | EXE_label of string (* for internal use only *)
  | EXE_goto of string  (* for internal use only *)
  | EXE_cgoto of expr_t (* for internal use only *)
  | EXE_ifgoto of expr_t * string  (* for internal use only *)
  | EXE_call of expr_t * expr_t
  | EXE_jump of expr_t * expr_t
  | EXE_loop of Flx_id.t * expr_t
  | EXE_svc of Flx_id.t
  | EXE_fun_return of expr_t
  | EXE_yield of expr_t
  | EXE_proc_return
  | EXE_halt of string
  | EXE_trace of Flx_id.t * string
  | EXE_nop of string
  | EXE_init of Flx_id.t * expr_t
  | EXE_iinit of (Flx_id.t * index_t) * expr_t
  | EXE_assign of expr_t * expr_t
  | EXE_assert of expr_t
  | EXE_try 
  | EXE_endtry
  | EXE_catch of Flx_id.t * typecode_t
  | EXE_proc_return_from of string

type sexe_t = Flx_srcref.t * exe_t

(** The whole of a compilation unit, this is the data structure returned by
 * parsing a whole file. *)
type compilation_unit_t = statement_t list

let src_of_qualified_name (e : qualified_name_t) = match e with
  | `AST_void s
  | `AST_name  (s,_,_)
  | `AST_case_tag (s,_)
  | `AST_typed_case (s,_,_)
  | `AST_lookup (s,_)
  | `AST_index (s,_,_)
  | `AST_callback (s,_)
  -> s

let src_of_suffixed_name (e : suffixed_name_t) = match e with
  | #qualified_name_t as x -> src_of_qualified_name x
  | `AST_suffix (s,_)
  -> s

let src_of_typecode = function
  | TYP_defer (s,_)
  | TYP_void s
  | TYP_name  (s,_,_)
  | TYP_case_tag (s,_)
  | TYP_typed_case (s,_,_)
  | TYP_lookup (s,_)
  | TYP_index (s,_,_)
  | TYP_callback (s,_)
  | TYP_suffix (s,_)
  | TYP_patvar (s,_)
  | TYP_patany s
  | TYP_type_extension (s,_,_)
  | TYP_tuple_cons (s,_,_)
  -> s

  | TYP_label
  | TYP_tuple _
  | TYP_unitsum _
  | TYP_sum _
  | TYP_intersect _
  | TYP_record _
  | TYP_polyrecord _
  | TYP_variant _
  | TYP_function _
  | TYP_cfunction _
  | TYP_pointer _
  | TYP_array _
  | TYP_as _
  | TYP_typeof _
  | TYP_var _
  | TYP_none
  | TYP_ellipsis
  | TYP_isin _
  | TYP_typeset _
  | TYP_setunion _
  | TYP_setintersection _
  | TYP_dual _
  | TYP_apply _
  | TYP_typefun _
  | TYP_type
  | TYP_type_tuple _
  | TYP_type_match _
  -> Flx_srcref.dummy_sr

let src_of_expr (e : expr_t) = match e with
  | EXPR_label (s,_)
  | EXPR_void s
  | EXPR_name (s,_,_)
  | EXPR_case_tag (s,_)
  | EXPR_typed_case (s,_,_)
  | EXPR_projection (s,_,_)
  | EXPR_rnprj (s,_,_,_)
  | EXPR_lookup (s,_)
  | EXPR_index (s,_,_)
  | EXPR_callback (s,_)
  | EXPR_suffix (s,_)
  | EXPR_patvar (s,_)
  | EXPR_patany s
  | EXPR_vsprintf (s,_)
  | EXPR_interpolate (s,_)
  | EXPR_ellipsis s
  | EXPR_noexpand (s,_)
  | EXPR_product (s,_)
  | EXPR_sum (s,_)
  | EXPR_intersect (s,_)
  | EXPR_isin (s,_)
  | EXPR_orlist (s,_)
  | EXPR_andlist (s,_)
  | EXPR_arrow (s,_)
  | EXPR_longarrow (s,_)
  | EXPR_superscript (s,_)
  | EXPR_map (s,_,_)
  | EXPR_apply (s,_)
  | EXPR_deref (s,_)
  | EXPR_new (s,_)
  | EXPR_ref (s,_)
  | EXPR_likely (s,_)
  | EXPR_unlikely (s,_)
  | EXPR_literal (s,_)
  | EXPR_tuple (s,_)
  | EXPR_tuple_cons (s,_,_)
  | EXPR_record (s,_)
  | EXPR_polyrecord (s,_,_)
  | EXPR_remove_fields (s,_,_)
  | EXPR_variant (s,_)
  | EXPR_record_type (s,_)
  | EXPR_polyrecord_type (s,_,_)
  | EXPR_variant_type (s,_)
  | EXPR_arrayof (s,_)
  | EXPR_lambda (s,_)
  | EXPR_match_ctor (s,_)
  | EXPR_match_variant (s,_)
  | EXPR_match_case (s,_)
  | EXPR_ctor_arg (s,_)
  | EXPR_variant_arg (s,_)
  | EXPR_case_arg (s,_)
  | EXPR_case_index (s,_)
  | EXPR_get_n (s,_)
  | EXPR_get_named_variable (s,_)
  | EXPR_coercion (s,_)
  | EXPR_as (s,_)
  | EXPR_as_var (s,_)
  | EXPR_match (s, _)
  | EXPR_type_match (s, _)
  | EXPR_typecase_match (s, _)
  | EXPR_cond (s,_)
  | EXPR_expr (s,_,_,_)
  | EXPR_letin (s,_)
  | EXPR_typeof (s,_)
  | EXPR_range_check (s,_,_,_)
  | EXPR_not (s,_)
  | EXPR_extension (s, _, _)
  | EXPR_get_tuple_tail (s,_)
  | EXPR_get_tuple_head (s,_)
  -> s

let src_of_stmt (e : statement_t) = match e with
  (*
  | STMT_public (s,_,_)
  *)
  | STMT_type_error (s,_)
  | STMT_try s
  | STMT_endtry s
  | STMT_catch (s,_,_)
  | STMT_private (s,_)
  | STMT_label (s,_)
  | STMT_goto (s,_)
  | STMT_cgoto (s,_)
  | STMT_assert (s,_)
  | STMT_init (s,_,_)
  | STMT_function (s,_,_,_,_,_,_)
  | STMT_reduce (s,_,_,_,_,_)
  | STMT_axiom (s,_,_,_,_)
  | STMT_lemma (s,_,_,_,_)
  | STMT_curry (s,_,_,_,_,_,_,_)
  | STMT_macro_val (s,_,_)
  | STMT_macro_forall (s,_,_,_)
  | STMT_val_decl (s,_,_,_,_)
  | STMT_lazy_decl (s,_,_,_,_)
  | STMT_var_decl (s,_,_,_,_)
  | STMT_ref_decl (s,_,_,_,_)
  | STMT_type_alias (s,_,_,_)
  | STMT_inherit (s,_,_,_)
  | STMT_inherit_fun (s,_,_,_)
  | STMT_nop (s,_)
  | STMT_assign (s,_,_,_)
  | STMT_cassign (s, _,_)
  | STMT_call (s,_,_)
  | STMT_jump (s,_,_)
  | STMT_loop (s,_,_)
  | STMT_svc (s,_)
  | STMT_fun_return (s,_)
  | STMT_yield (s,_)
  | STMT_proc_return s
  | STMT_proc_return_from  (s,_)
  | STMT_halt (s,_)
  | STMT_trace (s,_,_)
  | STMT_ifgoto (s,_,_)
  | STMT_ifreturn (s,_)
  | STMT_invariant (s,_)
  | STMT_ifdo (s,_,_,_)
  (*
  | STMT_whilst (s,_,_)
  | STMT_until (s,_,_)
  *)
  | STMT_abs_decl (s,_,_,_,_,_)
  | STMT_newtype (s,_,_,_)
  | STMT_ctypes (s,_,_,_)
  | STMT_const_decl (s,_,_,_,_,_)
  | STMT_fun_decl (s,_,_,_,_,_,_,_)
  | STMT_callback_decl (s,_,_,_,_)
  | STMT_insert (s,_,_,_,_,_)
  | STMT_code (s,_,_)
  | STMT_noreturn_code (s,_,_)
  | STMT_union (s, _,_,_)
  | STMT_struct (s,_,_,_)
  | STMT_cstruct (s,_,_,_,_)
  | STMT_typeclass (s,_,_,_)
  | STMT_instance (s,_,_,_)
  | STMT_untyped_module (s,_,_,_)
  | STMT_export_fun (s,_,_)
  | STMT_export_cfun (s,_,_)
  | STMT_export_python_fun (s,_,_)
  | STMT_export_type (s,_,_)
  | STMT_open (s,_,_)
  | STMT_inject_module (s,_,_)
  | STMT_include (s,_)
  | STMT_use (s,_,_)
  | STMT_seq (s,_)
  | STMT_scheme_string (s,_)
  | STMT_comment (s,_)
  | STMT_stmt_match (s,_)
  | STMT_export_struct (s,_)
  | STMT_export_union (s,_,_)
  | STMT_export_requirement (s,_)
  -> s

let src_of_pat (e : pattern_t) = match e with
  | PAT_coercion (s,_,_)
  | PAT_none s
  | PAT_literal (s,_)
  | PAT_range (s,_,_)
  | PAT_name (s,_)
  | PAT_tuple (s,_)
  | PAT_tuple_cons (s,_,_)
  | PAT_any s
  | PAT_setform_any s
  | PAT_const_ctor (s,_)
  | PAT_nonconst_ctor (s,_,_)
  | PAT_const_variant (s,_)
  | PAT_nonconst_variant (s,_,_)
  | PAT_as (s,_,_)
  | PAT_when (s,_,_)
  | PAT_record (s,_)
  | PAT_polyrecord (s,_,_)
  | PAT_expr (s,_)
  -> s

let typecode_of_qualified_name = function
  | `AST_void sr -> TYP_void sr
  | `AST_name (sr,name,ts) -> TYP_name (sr,name,ts)
  | `AST_case_tag (sr,v) -> TYP_case_tag (sr,v)
  | `AST_typed_case (sr,v,t) -> TYP_typed_case (sr,v,t)
  | `AST_lookup (sr,(e,name,ts)) -> TYP_lookup (sr,(e,name,ts))
  | `AST_index (sr,name,index) -> TYP_index (sr,name,index)
  | `AST_callback (sr,name) -> TYP_callback (sr,name)

let qualified_name_of_typecode = function
  | TYP_void sr -> Some (`AST_void sr)
  | TYP_name (sr,name,ts) -> Some (`AST_name (sr,name,ts))
  | TYP_case_tag (sr,v) -> Some (`AST_case_tag (sr,v))
  | TYP_typed_case (sr,v,t) -> Some (`AST_typed_case (sr,v,t))
  | TYP_lookup (sr,(e,name,ts)) -> Some (`AST_lookup (sr,(e,name,ts)))
  | TYP_index (sr,name,index) -> Some (`AST_index (sr,name,index))
  | TYP_callback (sr,name) -> Some (`AST_callback (sr,name))
  | _ -> None

(** Define a default vs_aux_t. *)
let dfltvs_aux =
  { raw_type_constraint = TYP_tuple []; raw_typeclass_reqs = []; }

(** Define a default vs_list_t. *)
let dfltvs = [], dfltvs_aux

