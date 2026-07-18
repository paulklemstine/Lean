# Computational Evidence

The formal model uses `Recipe n = Fin n → ZMod 2`, so its small cases have cardinalities:

| binary choices `n` | recipes |
|---:|---:|
| 0 | 1 |
| 1 | 2 |
| 2 | 4 |
| 3 | 8 |
| 4 | 16 |
| 5 | 32 |
| 6 | 64 |
| 7 | 128 |

These are the powers of two, proved uniformly by `RecipeHomotopy.card_recipe` rather than accepted from an external computation. No OEIS lookup is needed for this elementary sequence.

Counterexample hunting exposed an important qualification to the proposed `S⁰` example: two binary recipes are not isolated if the nut toggle is an allowed edge. They then form a one-edge cube, not a discrete two-point complex. The theorem `nuts_no_nuts_two_components` therefore states the `S⁰` analogue only for identity-method reachability.

For two distinct toggles, the four resulting recipes are pairwise distinct and both operation orders have the same endpoint. This square is certified by `toggle_square` and `toggle_square_vertices_distinct`. The theorem `transform_eq_self_iff` also rules out nonzero normalized loops in this model, so it supplies evidence against assigning a `ℤ` fundamental group without a richer, explicitly defined process space.
