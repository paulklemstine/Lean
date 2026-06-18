# Future Directions
## Functorial Tropicalization of p-adic Valuation–Depth Sublevel Filtrations into Persistence Modules

This cycle established the core bridge in
`Bridges/TropicalPersistenceFiltration.lean`:

* Sublevel/superlevel filtrations of an order-valued valuation are (anti)monotone functors
  into `(Set X, ⊆)` — set-valued **persistence modules** (`sublevel_monotone`,
  `superlevel_antitone`, `SetPersistenceModule`, `incl_refl`, `incl_trans`).
* Tropicalization `v ↦ ofSublevel v` is functorial in the valuation
  (`morphism_of_valuation_le`).
* The p-adic valuation depth `padicValNat p` realizes this: its superlevel sets are the
  ideals `pᵗ ℤ` (`padicValNat_superlevel_eq_dvd`), assembled into a genuine persistence
  module via the order dual (`padicPersistence`).
* The non-archimedean structure transfers: each level is closed under addition
  (`padicValNat_superlevel_add_closed`), multiplication by `p` is an interleaving shift by
  one (`padicValNat_mul_self`, `padicValNat_shift_morphism`), and the valuation is a
  tropical-semiring map (`padic_trop_mul`, `padic_trop_ultrametric`).

The following conjectures are **bold, precise, and testable** targets for follow-up cycles.

---

### Conjecture 1 — Interleaving distance of the ×k reparametrization
For a prime `p` and `k = pᵉ · m` with `p ∤ m`, multiplication by `k` shifts the p-adic
persistence module `padicPersistence p` by *exactly* `e = padicValNat p k`:
`padicValNat p (k * n) = padicValNat p n + e` for `n ≠ 0`.
Conjecture: the interleaving distance between `padicPersistence p` and its
`(k · ·)`-pushforward equals `padicValNat p k`, and this is realized by an explicit pair of
shift morphisms. **Testable**: state `padicValNat_mul_general` and a two-sided shift bound;
generalizes `padicValNat_shift_morphism` (the `k = p`, `e = 1` case).

### Conjecture 2 — Additive subgroup / submodule structure of every level
Each superlevel set `superlevel (padicValNat p) t` (together with `0`) is exactly the
additive subgroup `pᵗ ℤ` of `ℤ` (resp. an `ℤ`-submodule). Conjecture: the assignment
`t ↦ pᵗ ℤ` is a persistence module valued in `AddSubgroup ℤ` (not merely `Set`), the
structure maps are subgroup inclusions, and the associated graded `pᵗℤ / pᵗ⁺¹ℤ ≅ ℤ/pℤ` is
constant of "rank 1" at every step. **Testable**: build `padicPersistenceSubgroup` valued in
`AddSubgroup ℤ` and prove the graded-quotient isomorphism; upgrades
`padicValNat_superlevel_add_closed` from a closure property to a full submodule statement.

### Conjecture 3 — Stability / Lipschitz bound for valuation perturbations
For two valuations `v, w : X → ℕ` with `‖v − w‖_∞ ≤ δ` (pointwise), the sublevel persistence
modules `ofSublevel v` and `ofSublevel w` are `δ`-interleaved. Conjecture: a uniform bound
`d_interleave(ofSublevel v, ofSublevel w) ≤ sup_x |v x − w x|` holds, mirroring the classical
persistence stability theorem and the metric `sphere_perturbation_stability` of
`MetricFiltration.lean`. **Testable**: define an interleaving predicate on
`SetPersistenceModule ℕ X` and prove the bound; specialize to `v = padicValNat p`,
`w = padicValNat q` to compare primes.

### Conjecture 4 — Tropical homomorphism extends to a semiring/valuation functor
The map `n ↦ trop (padicValNat p n)` extends from `(ℕˣ-like nonzero) ℕ` to a homomorphism of
multiplicative-monoid-to-tropical-semiring structure, and the pair
(`padic_trop_mul`, `padic_trop_ultrametric`) exhibits `padicValNat p` as a *valuation* in the
sense of `TropicalValuationObject` from `CategoricalTropicalUltrametric.lean`. Conjecture:
there is a faithful functor from the p-adic data to a `TropicalValuationObject` instance whose
`add_eq_max'` law is precisely `padic_trop_ultrametric`. **Testable**: construct the
`TropicalValuationObject` instance and a structure-preserving map; this directly *connects*
the two catalog files at the object level rather than only at the lemma level.

### Conjecture 5 — Barcode / rank invariant is finite and computable on truncations
Restrict `padicPersistence p` to `{1, …, N}` (finite carrier). Conjecture: the rank invariant
`r(s, t) = |{n ≤ N : t ≤ padicValNat p n}|` equals `⌊N / pᵗ⌋` for `t = ofDual s = ofDual t`
boundaries, hence the persistence "barcode" of the truncated module is completely determined
by the geometric series `N, ⌊N/p⌋, ⌊N/p²⌋, …`, and its total persistence equals
`∑_{t ≥ 1} ⌊N / pᵗ⌋ = padicValNat p (N!)` (Legendre's formula). **Testable**: prove
`card_superlevel_eq_floor` and identify the total persistence with `padicValNat p (N !)`;
this is a fully computable, decidable check (`#eval`) and a sharp bridge between persistence
total-persistence and Legendre/de Polignac's formula.
