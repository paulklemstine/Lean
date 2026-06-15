# Future Directions — Functorial Lipschitz comparison: valuation depth ↔ tropical valuation objects

This cycle established that **valuation depth is the logarithmic shadow of the tropical
Lipschitz constant**: the exponential map `d ↦ base ^ d` is a comparison functor that turns
the max-plus depth law (`vdepth (f ∘ g) ≤ max (vdepth f) (vdepth g) + 1`) into the
multiplicative tropical Lipschitz law, and `Nat.log base` inverts it exactly, making the
comparison a 1-Lipschitz isometry. See `FunctorialDepthTropicalLipschitz.lean`.

Below are bold, testable conjectures for follow-up cycles. Each is phrased so it can be
formalized as a Lean statement and either proved or refuted.

## C1. Sub-additive (Fekete) depth limit and a tropical entropy
**Conjecture.** For any `MaxPlusDepthSystem` `S` and `a : S.Obj`, the normalized depth
`depth (iterC a n) / (n+1)` converges, and its limit equals the "tropical Lyapunov
exponent" `lim (log_base (tropShadow base (iterC a n))) / n`. Concretely the sequence
`n ↦ depth (iterC a n)` is sub-additive up to a constant, so `Nat.log`-normalized tropical
shadows have a well-defined growth rate independent of `base > 1`.
**Test.** Prove `depth (iterC a (m+n)) ≤ depth (iterC a m) + depth (iterC a n) + 1` and
derive a limit via a discrete Fekete lemma.

## C2. Strictness of the comparison (depth hierarchy ⇒ tropical-rate hierarchy)
**Conjecture.** The comparison functor is hierarchy-faithful: a `DepthWitness` separating
`VAL_k ⊊ VAL_{k+1}` (from `PadicValuationDepth`) transfers under `tropShadow base` to a
strict separation of tropical Lipschitz rate classes `{f | tropShadow base f ≤ base^k}`.
**Test.** Show `tropShadow base` is strictly monotone on depth (`d₁ < d₂ → base^{d₁} <
base^{d₂}` for `base ≥ 2`) and lift `strict_hierarchy_from_witness` across the functor.

## C3. Two-sided Lipschitz comparison with an additive defect
**Conjecture.** For genuinely *parallel* (non-iterated) composition the comparison loses no
more than the `+1` shift: there is a universal constant `c` with
`|log_base (tropShadow base (comp a b)) − max (depth a) (depth b)| ≤ c`, and `c = 1` is
sharp. More generally, for a balanced binary composition tree of `n` leaves, depth
`≤ ⌈log₂ n⌉ · (per-leaf depth + 1)`, matching the tropical product rate.
**Test.** Define a balanced-tree fold over `MaxPlusDepthSystem.comp` and bound its depth by
`Nat.log 2 n`, then compare to the tropical product of leaf shadows.

## C4. Functoriality of the comparison as a categorical natural transformation
**Conjecture.** `tropShadow base` extends to a functor on the morphism categories
(`UltraHom` / `TropValCarrierHom` from `CategoricalTropicalUltrametric`), and the
depth↔log-rate equality is a *natural isomorphism* between the depth grading and the
log of the tropical valuation grading. I.e. for every carrier morphism `φ`,
`log_base ∘ tropShadow base ∘ φ_* = φ_* ∘ depth` on the nose.
**Test.** Build a `MaxPlusDepthHom` structure (depth-nonexpansive maps) and prove
`tropShadow` preserves identities and composition, then prove the naturality square commutes.

## C5. p-adic realization: depth = valuation of a Hensel iteration count
**Conjecture.** Instantiating `MaxPlusDepthSystem` on `ℤ_[p]` endofunctions with
`depth f = ` number of Hensel-lifting steps recovers `HenselIterationComplexity`: the
tropical shadow `p ^ depth` equals the achieved p-adic precision, so
`depth = log_p(precision)` matches `HenselConvergenceData.precision_exponential`
(`precision ≥ 2^n`) with `base = 2`. This would unify the abstract comparison with the
concrete p-adic convergence theory in `PadicValuationDepth`.
**Test.** Define the Hensel `MaxPlusDepthSystem` and prove `tropShadow 2 (iterC a n) ≥
2 ^ n` reusing `precision_exponential`, then derive `depth = Nat.log 2 precision`.
