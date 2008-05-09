(** Display calcs *)

open Flx_types
open Flx_ast
open Flx_mtypes2

val get_display_list:
  sym_state_t ->
  fully_bound_symbol_table_t ->
  bid_t ->
  (bid_t * int) list

val cal_display:
  sym_state_t ->
  fully_bound_symbol_table_t ->
  bid_t option ->
  (bid_t * int) list

val strd:
  string list -> property_t list -> string
