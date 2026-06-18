# Future Directions — Proof-Theoretic Bridge: Ordinal Analysis Across Systems

The file `Catalog/Logic/OrdinalCollapsingBridge.lean` formalizes a genuine
fragment of ordinal analysis inside Mathlib's Veblen hierarchy. It works with
ε₀ = `veblen 1 0` (the proof-theoretic ordinal of Peano Arithmetic) and
Γ₀ = `gamma 0` = `nfp (veblen · 0) 0`, which in Bachmann–Buchholz ordinal
collapsing notation is exactly ψ(Ω^ω) (the Feferman–Schütte ordinal). The
headline result `eps0_lt_psiOmegaOmega` records ε₀ < ψ(Ω^ω); the centrepiece
new theorem `veblen_lt_gamma_zero` proves that Γ₀ is closed under the *binary*
Veblen function (`veblen o c < Γ₀` whenever `o, c < Γ₀`) — the precise sense in
which Γ₀ is *strongly critical*. From this we derive, with no `sorry`:
`ptStrength_lt_gamma_zero` (the diagonal "proof-strength" bridge stays below Γ₀),
`succ_lt_gamma_zero` (Γ₀ is closed under successor),
`epsilon_numbers_unbounded_below_gamma_zero` (epsilon numbers are cofinal below
Γ₀ — the direction left open in the seed concept is now closed),
`epsAt_lt_gamma_zero` (the whole tower ε₀ < ε₁ < ε₂ < ⋯ lands below Γ₀), and the
bundled `OrderEmbedding` `ptStrengthEmb`.

The five directions below are concrete and falsifiable: progress is measurable by
whether the corresponding Lean statement type-checks without `sorry`, building on
the exact definitions and lemmas already proven in the file.

## 1. A converse closure characterization: Γ₀ is the *least* strongly critical ordinal

We have proven the closure direction `veblen o c < Γ₀` for `o, c < Γ₀`. The
natural converse is that Γ₀ is the *least* ordinal with this property: if `δ` is
closed under binary Veblen (`∀ o c, o < δ → c < δ → veblen o c < δ`) and `0 < δ`,
then `Γ₀ ≤ δ`. **The key insight is** that closure under binary Veblen forces
`veblen δ 0 ≤ δ` (take a cofinal sequence of `veblen · 0` values below δ and use
normality), and Mathlib's `gamma_zero_le_of_veblen_le` turns `veblen δ 0 ≤ δ`
directly into `Γ₀ ≤ δ`. **Why now?** Combining the new `veblen_lt_gamma_zero`
with `gamma_zero_le_of_veblen_le` (already in Mathlib) gives a clean
extensional characterization `IsStronglyCritical δ ↔ δ = 0 ∨ δ ∈ range Γ_`,
making strong criticality a first-class predicate rather than a slogan.

## 2. Iterating the bridge: a normal `gamma`-tower closure

`ptStrengthEmb` packages `o ↦ veblen o 0` as an order embedding; the next rung is
to prove the *gamma* analogue of `epsAt_lt_gamma_zero`, namely that `Γ_` itself is
closed below the next strongly-critical-of-strongly-critical ordinal
`Γ_ Γ₀ = veblen (Γ₀) (Γ₀)`-style fixed point. Concretely: prove
`∀ o, o < Γ_ a → Γ_ o < Γ_ a` for limit `a`. **The key insight is** that
`gamma = deriv (veblen · 0)` is normal (`isNormal_gamma`), so its values below a
fixed point are cofinal and bounded exactly as `veblen` values are below Γ₀;
the proof is `veblen_lt_gamma_zero` with `gamma` in place of `veblen 1`. **Why
now?** `strictMono_gamma`, `gamma_lt_gamma`, and `veblen_gamma_zero` already supply
the monotonicity and fixed-point facts, so this is a relativization of the proof
we just completed rather than new theory.

## 3. Quantitative cofinality: an explicit increasing ω-sequence to Γ₀

`succ_lt_gamma_zero` and `epsilon_numbers_unbounded_below_gamma_zero` show
unboundedness; the next step is the *explicit* witness that
`Γ₀ = ⨆ n, (fun a ↦ veblen a 0)^[n] 0` is realized by a strictly increasing
ω-sequence of epsilon numbers, giving `Ordinal.cof Γ₀ = ω` (Γ₀ has countable
cofinality). **The key insight is** that the iterate `(veblen · 0)^[n] 0` is
strictly increasing because `veblen · 0` is strictly monotone with `veblen 0 0 =
1 > 0`, so the supremum is attained along a genuine ω-chain, not a stationary one.
**Why now?** `gamma_zero_eq_nfp`, `iterate_veblen_lt_gamma_zero`, and
`lt_gamma_zero` (all in Mathlib) already exhibit the sequence and its supremum;
only the strict-monotonicity-of-the-iterate wrapper plus `Ordinal.cof_eq_omega0`
machinery remains.

## 4. The bridge restricts to an order isomorphism onto the gamma-free segment

`ptStrengthEmb : o ↪o veblen o 0` is a global embedding; the refined claim is that
it restricts to an *order isomorphism* from `Set.Iio Γ₀` onto the set of
ordinals below Γ₀ that are not strongly critical (equivalently, the image of
`veblen · 0` below Γ₀). **The key insight is** that a strictly monotone map on a
linear order is automatically order-reflecting (already used to build
`ptStrengthEmb`), so the only new content is surjectivity onto the
fixed-point-free segment, which is exactly the range characterization
`mem_range_gamma` / `invVeblen₁_eq_iff` from Mathlib applied below Γ₀. **Why now?**
Mathlib's `OrderIso` API plus the just-proven `veblen_lt_gamma_zero` (which
guarantees the image lands in `Iio Γ₀`) make the bundling mechanical once the
range is pinned down by Direction 1.

## 5. Connect ε₀ to syntactic strength via Cantor normal form

Bridge the abstract ordinal ε₀ to the syntactic side by proving that Cantor
normal form base ω terminates exactly on ordinals `< ε₀`: ε₀ is the least
ordinal `a` with `ω ^ a = a`, hence the least ordinal not strictly reachable by
finite ω-base exponential towers `(fun x ↦ ω ^ x)^[n] 0`. **The key insight is**
that `omega0_opow_epsilon` (`ω ^ ε_ o = ε_ o`) is precisely the *failure* of CNF
to make progress, so ε₀ is the supremum of the iterated-exponential ordinals that
index PA proofs, exactly the content of `lt_epsilon_zero` /
`iterate_omega0_opow_lt_epsilon_zero`. **Why now?** Mathlib's
`Mathlib.SetTheory.Ordinal.CantorNormalForm` provides `Ordinal.CNF` with
completeness lemmas, and `epsilon_zero_eq_nfp` together with our
`epsilon_numbers_unbounded_below_gamma_zero` give the fixed-point boundary, so the
statement reduces to an induction on CNF length.
