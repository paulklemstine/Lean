# Computational Evidence — Analogy as a Mathematical Operation

This note records the small-case checks that motivated the formal theorems in
`AnalogyCore.lean`, `AnalogyConceptLattice.lean`, and `AnalogyOptimization.lean`.
The claims are ultimately settled by the Lean proofs; the evidence below is for
orientation only and is deliberately concise.

## 1. Distortion and the "perfect analogy is an equivalence" conjecture

We model an analogy as a pair `(F : A → B, G : B → A)` and score it by the
round-trip distortion `dist a (G (F a))`.

**Bold conjecture (contrarian):** *a perfect one-sided analogy is an
equivalence* — i.e. `G ∘ F = id_A` forces `F ∘ G = id_B`.

**Counterexample hunt.** Take `A = {•}` a single point, `B = ℝ`,
`F(•) = 0`, `G(x) = •`.

| quantity | value |
|---|---|
| `G (F •)` | `•`  (so `G ∘ F = id_A`, distortion `0`) |
| `F (G 1)` | `F • = 0` |
| `id_B 1`  | `1` |

Since `0 ≠ 1`, `F ∘ G ≠ id_B`. The conjecture is **FALSE**; this is formalized
as `Analogy.exists_perfect_oneSided_not_equiv`. (Any retraction that is not a
bijection witnesses the same phenomenon.)

## 2. Subadditivity of distortion (good analogies compose)

Composing analogies `A →(εf) B →(εg) C`, with `G_f` `L`-Lipschitz, the round
trip on `A` satisfies, by the triangle inequality,
`dist a (G_f (G_g (F_g (F_f a)))) ≤ εf + L·εg`.

Numerical sanity check (`A = B = C = ℝ`, `F_f = F_g = id`, `G_f(x) = x`,
`G_g(y) = y`, all Lipschitz constant `1`): with `εf = εg = 0` the bound gives
`0`, matching the exact identity round trip. Perturbing `G_g(y) = y + 0.1`
(so `εg = 0.1`) gives predicted bound `0 + 1·0.1 = 0.1`, and the actual
displacement is exactly `0.1`. The bound is tight. Formalized as
`Analogy.comp_fidelity`.

## 3. Optimization = tropical sum

A pool of candidate analogies with costs `cost : ι → ℝ` (distortions). The best
analogy has cost `min_i cost i`. In the min-plus (tropical) semiring,
`⊕ = min`, so aggregating candidate scores by *tropical addition* computes the
optimum directly.

Example pool with costs `[0.7, 0.2, 0.9, 0.5]`:

| operation | result |
|---|---|
| ordinary `min` | `0.2` |
| tropical sum `0.7 ⊕ 0.2 ⊕ 0.9 ⊕ 0.5` | `0.2` |
| attained by candidate | index `1` |

They agree, and the optimum is attained. Formalized as `tropicalScore_eq_inf`,
`tropicalScore_attained`, `tropicalScore_le`, and combined in
`tropicalScore_isBest`.

## 4. Concept-lattice (adjoint) model

The structure-preserving analogy between concept lattices is a Galois
connection `l ⊣ u`. Small poset checks:

- On the two-element chain `{0 < 1}` with `l = u = id`: `u (l a) = a` for all `a`
  (extensive with equality, zero distortion) — the copycat.
- For any Galois connection, `u ∘ l` is idempotent: on the chain, iterating the
  closure stabilizes after one step, as expected.
- Uniqueness: fixing `l = id`, the only adjoint `u` is `id`
  (`copycat_adjoint_unique`).

These are formalized as `adjointAnalogy_extensive`,
`adjointAnalogy_stable_closure`, `adjointAnalogy_stable_kernel`,
`adjoint_unique`, `copycat_isAdjoint`, and `copycat_adjoint_unique`.


# Computational Evidence — Analogy as a Mathematical Operation

This note records the small-case checks that motivated the formal theorems in
`AnalogyCore.lean`, `AnalogyConceptLattice.lean`, and `AnalogyOptimization.lean`.
The claims are ultimately settled by the Lean proofs; the evidence below is for
orientation only and is deliberately concise.

## 1. Distortion and the "perfect analogy is an equivalence" conjecture

We model an analogy as a pair `(F : A → B, G : B → A)` and score it by the
round-trip distortion `dist a (G (F a))`.

**Bold conjecture (contrarian):** *a perfect one-sided analogy is an
equivalence* — i.e. `G ∘ F = id_A` forces `F ∘ G = id_B`.

**Counterexample hunt.** Take `A = {•}` a single point, `B = ℝ`,
`F(•) = 0`, `G(x) = •`.

| quantity | value |
|---|---|
| `G (F •)` | `•`  (so `G ∘ F = id_A`, distortion `0`) |
| `F (G 1)` | `F • = 0` |
| `id_B 1`  | `1` |

Since `0 ≠ 1`, `F ∘ G ≠ id_B`. The conjecture is **FALSE**; this is formalized
as `Analogy.exists_perfect_oneSided_not_equiv`. (Any retraction that is not a
bijection witnesses the same phenomenon.)

## 2. Subadditivity of distortion (good analogies compose)

Composing analogies `A →(εf) B →(εg) C`, with `G_f` `L`-Lipschitz, the round
trip on `A` satisfies, by the triangle inequality,
`dist a (G_f (G_g (F_g (F_f a)))) ≤ εf + L·εg`.

Numerical sanity check (`A = B = C = ℝ`, `F_f = F_g = id`, `G_f(x) = x`,
`G_g(y) = y`, all Lipschitz constant `1`): with `εf = εg = 0` the bound gives
`0`, matching the exact identity round trip. Perturbing `G_g(y) = y + 0.1`
(so `εg = 0.1`) gives predicted bound `0 + 1·0.1 = 0.1`, and the actual
displacement is exactly `0.1`. The bound is tight. Formalized as
`Analogy.comp_fidelity`.

## 3. Optimization = tropical sum

A pool of candidate analogies with costs `cost : ι → ℝ` (distortions). The best
analogy has cost `min_i cost i`. In the min-plus (tropical) semiring,
`⊕ = min`, so aggregating candidate scores by *tropical addition* computes the
optimum directly.

Example pool with costs `[0.7, 0.2, 0.9, 0.5]`:

| operation | result |
|---|---|
| ordinary `min` | `0.2` |
| tropical sum `0.7 ⊕ 0.2 ⊕ 0.9 ⊕ 0.5` | `0.2` |
| attained by candidate | index `1` |

They agree, and the optimum is attained. Formalized as `tropicalScore_eq_inf`,
`tropicalScore_attained`, `tropicalScore_le`, and combined in
`tropicalScore_isBest`.

## 4. Concept-lattice (adjoint) model

The structure-preserving analogy between concept lattices is a Galois
connection `l ⊣ u`. Small poset checks:

- On the two-element chain `{0 < 1}` with `l = u = id`: `u (l a) = a` for all `a`
  (extensive with equality, zero distortion) — the copycat.
- For any Galois connection, `u ∘ l` is idempotent: on the chain, iterating the
  closure stabilizes after one step, as expected.
- Uniqueness: fixing `l = id`, the only adjoint `u` is `id`
  (`copycat_adjoint_unique`).

These are formalized as `adjointAnalogy_extensive`,
`adjointAnalogy_stable_closure`, `adjointAnalogy_stable_kernel`,
`adjoint_unique`, `copycat_isAdjoint`, and `copycat_adjoint_unique`.
