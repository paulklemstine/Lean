# FUTURE DIRECTIONS
## Tropical valuation profiles of Berggren-tree lattice reduction

Companion to `Catalog/Cryptography/TropicalBerggrenProfiles.lean`. Each item below is
a precise, falsifiable conjecture for a follow-up cycle, with a suggested first Lean
experiment. Naming refers to declarations in that file and in
`Algebra/BerggrenLorentz/Core.lean`.

---

### Conjecture 1 — Exact tropical recurrence for the even-leg valuation
We proved `v₂(b) ≥ 2` is conserved (`v2_profile`), but experiments show the *exact*
value moves: `(3,4,5)` has `v₂(b)=2`, its `C`-child `(15,8,17)` has `v₂(b)=3`.

> **Claim.** For a profiled triple `(a,b,c)`, the even-leg valuation under the three
> generators obeys the tropical (min-plus) recurrence
> `v₂(childX.b) = 1 + min(v₂(a+c or a−c term), v₂(b))`,
> and in particular `A,B` fix `v₂(b)` while `C` can strictly raise it.

*First experiment.* Prove `padicValInt 2 (childA a b c).2.1 = padicValInt 2 b` under
`ValProfile`, and find/refute the analogous closed form for `C`.

---

### Conjecture 2 — The profile mod 2ᵏ is a finite-state automaton invariant
`parity_mod2_invariant_*` shows the residue vector mod 2 is *pointwise fixed*. Mod 4
the even leg is fixed at `0` but the odd legs are not.

> **Claim.** For each `k`, the map `(a,b,c) ↦ (a,b,c) mod 2ᵏ` factors the Berggren
> action through a finite monoid `M_k ⊆ (ℤ/2ᵏ)³`, and the reachable residues from the
> seed form a strict, computable sub-automaton whose size is `Θ(2^{k})` (not `2^{3k}`).

*First experiment.* `decide`-check the reachable residues mod 8 and mod 16 from
`(3,4,5)`; conjecture the growth law and prove closure (`applyGen` stays in the set).

---

### Conjecture 3 — Tropical cost is a sharp two-sided depth oracle
We bounded `3|w| ≤ tropCost w ≤ 5|w|` (`tropCost_lower/upper`) and showed strict
hypotenuse growth (`berggren_orbit_depth_lower`: `5c < childB.c`).

> **Claim.** Along any word `w`, `log₂(hyp(applyWord w seed)) = Θ(tropCost w)`; more
> precisely `tropCost w · log₂(φ) ≤ log₂(hyp) ≤ tropCost w · log₂(3+2√2)` for a fixed
> spectral constant, making `tropCost` a certified `Θ(log c)` reversal-depth oracle
> (the post-quantum key-orbit hardness measure).

*First experiment.* Prove `c · 3^{|w|} ≤ hyp(applyWord w (a,b,c))` for positive
profiled triples by `foldl` induction reusing `berggren_orbit_depth_lower`.

---

### Conjecture 4 — Ultrametric ⇒ collision-freeness of orbit hashing
`padicValInt_two_ultrametric` gives the valuation the ultrametric axiom, and
`applyWord_preserves_pythag` keeps every node on the light cone.

> **Claim.** The map `w ↦ (hyp(applyWord w seed) mod N)` is *injective on words of
> bounded tropical cost* whenever `N` exceeds the spectral radius bound of
> Conjecture 3; equivalently the Berggren word problem has no short collisions, a
> certified one-wayness statement in the style of `Cryptography/CSIFiShAdvanced`.

*First experiment.* Formalize injectivity of `applyWord · seed` on all words (the tree
has unique paths, since the generators are invertible — reuse `invA/invB/invC` from
Core) and quantify the modulus needed to preserve it after reduction mod `N`.

---

### Conjecture 5 — Positivity is a fourth conserved charge (well-founded reduction)
`berggren_reduction_terminates` needs `0 < a,b,c` as hypotheses; we have not yet shown
positivity is *preserved* by the action.

> **Claim.** `0 < a ∧ 0 < b ∧ 0 < c` is conserved by every generator on profiled
> Pythagorean triples, hence the descending hypotenuse chain under reduction is
> genuinely well-founded — a concrete ACC instance bridging to
> `Cryptography/NoetherianCertification`. Therefore `applyWord` from the seed lands in
> the strictly positive cone for all `w`, and orbit reversal terminates unconditionally.

*First experiment.* Prove `applyGen_preserves_pos` (case split + `nlinarith` using the
Pythagorean and triangle inequalities), lift it through `foldl`, and combine with
`berggren_reduction_terminates` to obtain a `WellFounded` reduction relation.
