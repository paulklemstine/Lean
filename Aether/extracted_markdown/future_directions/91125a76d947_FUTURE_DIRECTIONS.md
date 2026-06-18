# FUTURE_DIRECTIONS — Proof-Theoretic Bridge: Ordinal Analysis Across Systems

## Synthesis

This cycle built a *closure-theoretic* bridge between formal systems and their
proof-theoretic ordinals, working entirely inside Mathlib's Veblen hierarchy
(`Ordinal.epsilon = veblen 1`, `Ordinal.gamma = deriv (veblen · 0)`). The organizing
thesis is that the proof-theoretic ordinal of a system is *precisely the ordinal closed
under the operations that system can iterate*: addition and `ω`-exponentiation for Peano
Arithmetic (`ε₀`), and the binary Veblen function for predicative analysis (`Γ₀`). We
turned this slogan into theorems. For the `ε`-family we proved additive principality
(`epsilon_principal_add`) and closure under base-`ω` exponentiation (`epsilon_opow_lt`),
both extracted from the single fixed-point identity `ω ^ (ε_ o) = ε_ o`. For the
`Γ`-family we proved the headline closure result `gamma_principal_veblen`: every `Γ_ o`
is principal under the *binary* Veblen function — a result Mathlib's own `Veblen.lean`
header explicitly lists as unproven future work.

The decisive structural discovery was that the entire converse direction collapses to a
single lemma: a veblen-principal ordinal `o ≥ ω` is a fixed point of the diagonal
`veblen · 0` (`principal_veblen_fixed`). Once that lemma is in hand, both "Γ₀ is the
least infinite veblen-principal ordinal" (`gamma_zero_least_veblen_principal`) and the
full characterization "veblen-principal ↔ in the range of `Γ_`"
(`veblen_principal_iff_mem_range_gamma`) follow in a few lines via `mem_range_gamma` and
`gamma_zero_le_of_veblen_le`. The proof of the key lemma itself splits cleanly into a
limit-ordinal argument (a successor `succ b` cannot be principal because `lt_veblen`
forces `b < veblen b b`) and an order-continuity argument (`isNormal_veblen_zero`).

What failed and what it taught us: an initial machine-found proof of
`principal_veblen_fixed` routed through an explicit `⨆ a : Set.Iio o` supremum and was
*rejected by the kernel* — it acquired four spurious universe parameters where the
declaration allows one (`AddConstAsyncResult.commitConst: constant has level params
[u_1, u_2, u_3, u_4] but expected [u_1]`). Replacing the subtype-supremum with
`IsNormal.le_iff_forall_le` (which quantifies `∀ b < o` and stays in a single universe)
removed the pathology entirely. The lesson is concrete and reusable: in
universe-monomorphic `Ordinal` lemmas, prefer the `∀ b < o`-style normal-function API
over explicit `Set.Iio`-indexed suprema. A second, smaller failure: the `ε_`/`Γ_`
notations are *ambiguous* with `CategoryTheory`'s exact-pairing `ε_` under
`import Mathlib`; we use the bare function names `epsilon`/`gamma` throughout.

## Results Summary

- `epsilon_principal_add`: proved — every `ε_ o` is additively principal (PA-style additive closure of the proof-theoretic ordinal).
- `epsilon_add_lt`: proved — explicit `a,b < ε_ o ⟹ a+b < ε_ o` form.
- `epsilon_opow_lt`: proved — every `ε_ o` is closed under `a ↦ ω^a`, the defining property of `ε₀` as the ordinal of PA.
- `gamma_veblen_lt`: proved — `a,b < Γ_ o ⟹ veblen a b < Γ_ o` (predicative closure under the binary Veblen function).
- `gamma_principal_veblen`: proved — `Γ_ o` packaged as `Principal veblen (gamma o)`; forward half of a characterization Mathlib lists as open.
- `gamma_principal_add`: proved — `Γ_ o` is additively principal (inherited via the `veblen 0` fixed-point identity).
- `system_ordinal_tower`: proved — the strict cross-system chain `ω < ε₀ < ε₁ < Γ₀ < Γ₁`.
- `epsilon_zero_lt_gamma_zero`: proved — PA's ordinal sits strictly below the Feferman–Schütte ordinal.
- `principal_veblen_fixed`: proved — a veblen-principal `o ≥ ω` satisfies `veblen o 0 = o` (the structural crux of the converse).
- `gamma_zero_least_veblen_principal`: proved — `Γ₀` is the least infinite veblen-principal ordinal.
- `veblen_principal_iff_mem_range_gamma`: proved — full characterization: an ordinal `≥ ω` is veblen-principal iff it is some `Γ_ o`.

## Research Directions

### Direction 1: Drop the `ω ≤ o` hypothesis from the characterization
**Hypothesis**: `Principal veblen o ↔ (o = 0 ∨ o ∈ Set.range gamma)` for *all* `o`, with no
infiniteness assumption.
**Test**: Prove it. The finite/small cases must be checked directly: `veblen 0 0 = ω^0 = 1`,
so `Principal veblen 1` fails (it would need `veblen 0 0 < 1`), and likewise every finite
`o > 0` fails; `0` is vacuously principal. So the disjunct `o = 0` is the only addition
needed, and `principal_veblen_fixed` should generalize once `ω ≤ o` is replaced by `o ≠ 0`
plus a finite-case elimination.
**Why now**: `veblen_principal_iff_mem_range_gamma` already proves the hard infinite case;
only a bounded computation on finite ordinals remains, which `decide`/`omega`-style
reasoning on `veblen 0 0 = 1` can close. The key insight is that finiteness is not used
anywhere in the limit/continuity argument — the only role of `ω ≤ o` is to guarantee
`0 < o` and rule out small successors, both of which have elementary replacements.
**If true**: Mathlib gains the clean, hypothesis-free theorem its `Veblen.lean` header
advertises as future work, ready for upstreaming.
**If false**: there is an unexpected small veblen-principal ordinal, which would be a
genuine surprise about the base of the Veblen hierarchy.

### Direction 2: Iterate the bridge to higher fixed-point levels (the small Veblen ordinal)
**Hypothesis**: The closure pattern `ε` (fixed points of `ω^·`) → `Γ` (fixed points of
`veblen · 0`) continues: define `Φ` enumerating the fixed points of `o ↦ veblen o 0 0`
(ternary Veblen diagonal), and then `Φ_ o` is principal under the *ternary* Veblen
function, with `Γ₀ < Φ₀`.
**Test**: Formalize the ternary Veblen function (or use `Ordinal.veblen` iterated / the
`Veblen`-over-`Veblen` construction) and replay `gamma_veblen_lt` one level up.
**Why now**: `gamma_veblen_lt`'s proof used only (i) a fixed-point identity and (ii) the
trichotomy `veblen_lt_veblen_iff`. The key insight is that *any* normal diagonal with a
matching trichotomy lemma admits the identical three-line closure proof, so the argument
is level-agnostic and should lift verbatim.
**If true**: a uniform, machine-checked ladder of predicative-strength ordinals, the
scaffolding for formalizing the small Veblen ordinal and beyond.
**If false**: the trichotomy lemma fails to generalize, pinpointing exactly where binary
Veblen structure is special.

### Direction 3: Connect the ordinal landmarks to a syntactic provability measure
**Hypothesis**: There is an order-embedding from a concrete notation system (Cantor normal
forms below `ε₀`, as finite multisets of exponents) into `Ordinal`, whose image is exactly
`Set.Iio ε₀`, and on which a Goodstein-style descent is well-founded *because* of
`epsilon_opow_lt`.
**Test**: Define `CNF`-style notations over `ℕ`, an evaluation map to `Ordinal`, prove it
is a strict-order embedding with image `Iio (epsilon 0)`, and derive termination of the
descent from well-foundedness of `<` on `Ordinal` pulled back along the embedding.
**Why now**: `epsilon_opow_lt` already certifies that the notation operations stay below
`ε₀`. The key insight is that the *closure* theorems proved this cycle are exactly the
side conditions a notation-system soundness proof needs — closure under `ω^·` is what
keeps evaluated notations inside `Iio ε₀`.
**If true**: a bridge from the abstract ordinal landmarks to an executable termination
certificate, the semantic half of a Gentzen-style consistency argument.
**If false**: the embedding's image overshoots or undershoots `Iio ε₀`, exposing a
mismatch between the notation calculus and the analytic definition of `ε₀`.

### Direction 4: Quantify the gaps in the tower (additive/multiplicative density)
**Hypothesis**: Between consecutive landmarks the closure ordinals are *dense* in a precise
sense: for every `a < ε₀` there are unboundedly many additively principal ordinals strictly
between `a` and `ε₀`, namely the `ω^b` for `a < ω^b < ε₀`.
**Test**: Prove `∀ a < ε₀, ∃ b, a < ω^b ∧ ω^b < ε₀ ∧ Principal (·+·) (ω^b)`, combining
`epsilon_opow_lt`, `lt_epsilon_zero`, and `principal_add_omega0_opow`.
**Why now**: `epsilon_opow_lt` plus the iterate characterization `lt_epsilon_zero`
(`o < ε₀ ↔ ∃ n, o < (ω^·)^[n] 0`) make the witness explicit. The key insight is that the
fixed-point ε-ordinals are *limits of their own additive principals*, so density is a
direct corollary rather than a new argument.
**If true**: a structural refinement of `system_ordinal_tower` showing the tower's gaps are
themselves richly stratified.
**If false**: there is an additive-principal gap below `ε₀`, contradicting the standard
picture of additive principals as exactly the `ω^b`.

### Direction 5: A reflection-style strict inequality `Γ₀ < Γ₀·2`-analogue via normality
**Hypothesis**: `gamma` being normal yields a self-strengthening hierarchy: for every `o`,
`Γ_ o < Γ_ (o+1)` and `Γ_ (o+1)` is itself a fixed point of `veblen · 0` above `Γ_ o`, so
the map `o ↦ Γ_ o` has its *own* fixed point, the first ordinal `α` with `Γ_ α = α` (the
"Ackermann/large Veblen" threshold).
**Test**: Use `isNormal_gamma` and `IsNormal`'s fixed-point machinery (`deriv`, `nfp`) to
construct `α` with `Γ_ α = α` and prove `Γ₀ < α`.
**Why now**: `gamma_principal_veblen` and `strictMono_gamma` are in place; the only new
ingredient is applying Mathlib's `deriv`/`nfp` to `gamma` itself. The key insight is that
the closure construction is *self-applicable* — the operation that builds `Γ` from `veblen`
can be re-fed its own output.
**If false**: `gamma` lacks the needed continuity at the relevant limit, marking the exact
boundary where predicative iteration stops being self-sustaining.
