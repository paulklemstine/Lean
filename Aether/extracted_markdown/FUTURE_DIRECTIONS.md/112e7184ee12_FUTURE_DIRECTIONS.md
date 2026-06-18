# FUTURE_DIRECTIONS — Tropicalization of Berggren Dynamics

Seeded by `Catalog/Bridges/TropicalBerggrenSemigroup.lean` (integer max-plus shadow of
the Berggren tree of primitive Pythagorean triples). This file drives the next cycle.

## Synthesis

This cycle built an **integer, exact** max-plus (tropical) shadow of the Berggren
generation machinery and asked which classical structure survives tropicalization. Three
things survive cleanly, and one fails informatively. (1) The *algebra* survives perfectly:
the tropical matrix product realizes operator composition `trop(M ⊙ N) = tropM ∘ tropN`
**on the nose and sign-free** (`tropMV_comp`, `tropMM_assoc`), each operator is monotone
(`tropMV_mono`), and the word action is a homomorphism `tropAct (u ++ w) = tropAct u ∘
tropAct w` (`tropAct_append`) — the tropical mirror of the catalog `evalWord_append`.
(2) The *growth* survives as a logarithm-free sandwich: for nonnegative data the max-times
shadow brackets the classical linear action within a factor `n = 3`
(`berggrenB_growth_sandwich`), and — the cycle's sharpest structural find — the *lower*
half of the sandwich composes along an entire word with **no constant loss**
(`subIter_le_linIter`), turning the tropical recursion into a certified lower bound on
classical coordinate growth read directly from the word. (3) The *Lorentz constraint*
survives as a quasi-invariant: on the Pythagorean light cone `max(a²,b²) ≤ c² ≤ 2·max(a²,b²)`
(`lorentz_trop_balance`), an invariant of the whole tree because every generator preserves
the relation (`lorentz_trop_balance_childA/B/C`); the root shows the factor 2 is tight
(`lorentz_trop_balance_tight`).

What **failed** is the naive hope of a *faithful* integer max-plus model. Taking
absolute values collapses all three generators to `matB` (`genAbsMat_eq`), so the tropical
word action depends only on word *length* (`tropAct_unfaithful`) — a stark contrast with
the catalog freeness/injectivity of the exact action. The Critic localized the obstruction
precisely: the lower sandwich already breaks for the *signed* generator A at the root
(`subMV_not_le_linMV_A`, `10 ≤ 5` is false), because sign cancellation lets a row sum drop
below its largest term. So sign data is exactly what tropicalization-by-magnitude destroys,
and recovering it is the central open problem.

The structural insight tying these together: max-plus is the faithful shadow of the
*multiplicative, nonnegative* part of the dynamics (semigroup law + monotonicity + lower
growth bound), while signs are a genuinely non-tropical datum that must be re-introduced
by hand (signed tropical numbers) to recover faithfulness. The next cycle should (a) sharpen
the *upper* growth constant from `3^k` toward the true exponential base, and (b) build the
signed model and prove it faithful.

## Results Summary

- `tropMV_comp`: proved — tropical product = operator composition, exact and sign-free; the semigroup law of the action.
- `tropMM_assoc`: proved — max-plus matrix product is associative.
- `tropMV_mono`: proved — every tropical operator is order-preserving.
- `tropAct_append`: proved — tropical word action is a homomorphism (mirror of catalog `evalWord_append`).
- `subMV_le_linMV` / `linMV_le_card_subMV` / `linMV_le_three_subMV`: proved — two-sided growth sandwich (factor `n`), the logarithm-free integer bridge.
- `berggrenB_growth_sandwich`: proved — sandwich specialized to the all-positive generator B.
- `subIter_le_linIter`: proved — the lower sandwich composes along a whole B-word with no constant loss (certified growth lower bound from the word).
- `lorentz_trop_balance` (+ `_childA/B/C`, `_tight`): proved — tropical Lorentz quasi-invariant `max(a²,b²) ≤ c² ≤ 2·max(a²,b²)`, tree-invariant, factor 2 tight.
- `tropAct_unfaithful`: proved (negative result) — absolute-value tropicalization is not faithful; it sees only word length.
- `subMV_not_le_linMV_A`: proved (counterexample) — the lower sandwich fails for the signed generator A at the root, isolating why only B is two-sided.

## Research Directions

### Direction 1: The sharp exponential base of the upper growth sandwich
**Hypothesis**: There is a constant `C` and a base `ρ` with `1 < ρ < 3` such that
`linIter k v i ≤ C · ρ^k · subIter k v i` for all nonnegative `v`, with `ρ = λ_B / μ_B`
the ratio of the classical Perron eigenvalue `λ_B = 3 + 2√2` of `matB` to its max-times
("tropical") eigenvalue `μ_B = 3`; equivalently `ρ = (3 + 2√2)/3 ≈ 1.943`.
**Test**: Prove the iterated upper bound `linIter k v i ≤ 3^k · subIter k v i` first (a
direct induction from `linMV_le_three_subMV` + `linMV_mono` + scaling of `subMV`), then
attempt to replace `3^k` by `C·ρ^k` using a Perron eigenvector of `matB` as a weight; a
disproof would exhibit a starting cone direction where the ratio grows like `3^k`.
The key insight is that the lower side already composes losslessly (`subIter_le_linIter`),
so the entire approximation defect is one-sided and governed by the *gap between the
classical and tropical spectral radii*, not by per-step slack.
**Why now**: This cycle proved the per-step factor (`= n = 3`) and the lossless lower
composition, leaving the upper constant as the only moving part; the Pell/spectral data
for `matB` already exists in `Computation/QuantumBerggrenWalk.lean` (B-branch hypotenuse
recurrence), so the eigenvalue `3 + 2√2` is in reach.
**If true**: Gives a tight tropical estimator of Berggren descendant size from the word
alone, with a provable approximation ratio — directly useful to the lattice-reduction
heuristics in `Cryptography/BerggrenLatticeReduction.lean`.
**If false**: Pinpoints a cone direction where tropical and classical growth genuinely
diverge exponentially, exposing a limit of all max-times size estimators.

### Direction 2: A faithful *signed* tropical Berggren model
**Hypothesis**: Equipping states with the signed tropical numbers of
`Catalog/Tropical/BerggrenTropicalBridge.lean` (`SignedTropical = sign × magnitude`) and
defining `tropMV` with a sign-aware max yields a *faithful* action: distinct words give
distinct signed-tropical actions on the root, recovering the catalog freeness.
**Test**: Define the signed max-plus operators for `matA`, `matB`, `matC`, prove they no
longer collapse (`genSignedMat_ne` for the pairs A≠B, B≠C, A≠C), then prove an injectivity
theorem `signedTropAct_root_injective` and compare with `tropAct_unfaithful`. A disproof
would show two distinct words colliding even with signs.
The key insight is that this cycle's `tropAct_unfaithful` localizes the entire failure of
faithfulness to the *discarded column signs*, so re-attaching exactly that one bit per entry
is both necessary and plausibly sufficient.
**Why now**: We now have a precise negative baseline (collapse-by-length) and a matching
counterexample (`subMV_not_le_linMV_A`) that both isolate sign as the missing datum; the
`SignedTropical` structure is already in the catalog awaiting an action.
**If true**: First faithful tropical shadow of a free Pythagorean semigroup — a genuine
bridge from exact Diophantine generation to signed max-plus dynamics.
**If false**: Shows that faithfulness needs strictly more than one sign bit per entry,
e.g. full ordered-field valuations, reshaping the whole tropicalization program.

### Direction 3: Tropical Lorentz balance as a quantitative tree-depth oracle
**Hypothesis**: Iterating the balance `max(a²,b²) ≤ c² ≤ 2·max(a²,b²)` along a length-`k`
word gives `2^{-k} · (initial max) ≤ (final c²) / (final max of squared legs)`-type
control, so the tropical hypotenuse height `log c` grows by a per-edge increment in a fixed
bounded interval, yielding two-sided `Θ(k)` bounds on tree depth versus `log c`.
**Test**: Prove `c² ≤ 2·max(a²,b²)` iterates to `c_k² ≤ 2^k · (max leg square)_0` and
combine with the catalog `height_lower_bound_length` to sandwich depth between `c·log c`
multiples; disproof = a branch where the defect telescopes sub-linearly.
The key insight is that the balance defect is *exactly* `log 2` per Pythagorean node
regardless of which generator fires, so depth is an additive tropical cocycle up to that
fixed defect.
**Why now**: The balance and its tree-invariance (`lorentz_trop_balance_child*`) were
established this cycle, and the catalog already has the matching classical depth bound to
sandwich against.
**If true**: A purely tropical, generator-agnostic proof of `O(log c)` Berggren depth,
complementing the algebraic catalog proof.
**If false**: Reveals generator-dependent depth defects, refining the tree's metric
geometry.

### Direction 4: Tropical idempotency / Kleene-star closure of the Berggren operators
**Hypothesis**: The tropical operator `tropMV matB` admits a max-plus Kleene star
`B* = sup_k B^{⊙k}` that is *finite* on the light-cone cone and equals a fixed explicit
piecewise-linear operator, giving closed-form asymptotics of the B-branch.
**Test**: Show `B^{⊙(k+1)} = B^{⊙k}` beyond some `k₀` on the cone (eventual idempotence of
max-plus powers of an irreducible matrix), reusing the catalog `Tropical/BellmanFord.lean`
/ `KleeneStarUpdate.lean` machinery; disproof = unbounded growth of all powers (expected
off the normalized cone, so the statement must be on the projectivized cone).
The key insight is that max-plus powers of a primitive matrix become eventually periodic
(cyclicity theorem), so the infinite B-branch has a finite tropical "transfer operator."
**Why now**: This cycle isolated `matB` as the unique well-behaved generator and provided
its tropical operator; the catalog's Bellman–Ford/Kleene-star files give ready closure
infrastructure to plug in.
**If true**: Closed-form tropical asymptotics for the entire B-spine, an exact computable
growth law.
**If false**: Indicates the Berggren tropical operator is not cyclic in the standard sense,
an unusual and interesting max-plus phenomenon worth its own study.

### Direction 5: Generalize the bridge beyond `Fin 3` to higher Pythagorean / Lorentz trees
**Hypothesis**: The composition law, monotonicity, and growth sandwich (all proved here for
general `Fin n`) instantiate verbatim for the `O(n-1,1;ℤ)` generator families of
higher-dimensional Pythagorean tuples (`a₁² + … + a_{n-1}² = a_n²`), with the sandwich
factor `n` and a Lorentz balance `max_i(a_i²) ≤ a_n² ≤ (n-1)·max_i(a_i²)`.
**Test**: Define the higher Berggren generators, instantiate `tropMV_comp`/`subMV_le_linMV`
(already `Fin n`-general), and prove the `(n-1)`-factor Lorentz balance by the same `omega`
argument; disproof = a higher generator with a negative row sum breaking nonnegativity even
for the positive branch.
The key insight is that nothing in the core algebra of this cycle used `n = 3` — only the
Berggren-specific `matB`, `decide`, and `nlinarith` steps did — so the general theorems are
already waiting to be reused.
**Why now**: The file was deliberately written with `variable {n : ℕ} [NeZero n]`, so the
`Fin n` scaffolding is in place and only the higher generators and one balance lemma are
missing.
**If true**: A uniform tropical theory of Lorentzian Diophantine trees in all dimensions,
a broad cross-domain bridge (number theory ↔ max-plus ↔ O(n-1,1) geometry).
**If false**: Identifies the dimension at which the positive-branch nonnegativity (hence the
clean shadow) breaks, a sharp structural threshold.
