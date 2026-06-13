import Mathlib

open scoped Topology

/-!
# The Oracle Counting Barrier

This file isolates the *cardinal mechanism* behind the bridge between
finite-description complexity and three-valued oracle non-computability, and reduces
it to a single, domain-agnostic counting fact.

A **three-valued oracle** on `N` statements is a function `Fin N → Fin 3`: it assigns
to each statement one of three verdicts (e.g. `true` / `false` / `undetermined`). A
**program space** `P` together with a *compilation* `f : P → (Fin N → Fin a)` models
a finite family of descriptions, each of which names one oracle. The barrier says:
once the program space is strictly smaller than the oracle space, some oracle escapes
every compilation — *for any* answer alphabet, and the number `3` plays no role in this
coverage obstruction. The number `3` enters only the *information* story, where it
produces the binary deficit `2 ^ N < 3 ^ N` and, sharpened, the exact rate `(2/3) ^ N`.

## Main results

* `oracle_card` — there are exactly `3 ^ N` three-valued oracles on `N` statements.
* `oracle_not_covered_generic` — the reusable, alphabet-agnostic barrier.
* `oracle_not_covered` — the `a = 3` specialization.
* `budget_gap_exists` — every fixed budget `b ^ k` is eventually outrun by `3 ^ N`.
* `binary_insufficient` — `2 ^ N < 3 ^ N` for `N ≥ 1`.
* `computable_fraction_tendsto_zero` — for any constant budget, the nameable fraction
  `C / 3 ^ N → 0`.
* `binary_fraction_eq` — the exact geometric law `2 ^ N / 3 ^ N = (2/3) ^ N`.
* `binary_fraction_tendsto_zero` — that exact fraction vanishes geometrically.

Catalog connections: `Computation/OracleBurden.lean` (oracle jump hierarchy via
provability sets) and `Computation/Oracles/Foundation.lean` (geodesic idempotent
oracles). This file supplies the single counting lemma those chains can specialize,
replacing an ascending sequence of separations by one cardinal inequality.
-/

/-- A three-valued oracle on `N` statements: each statement receives one of three
verdicts. -/
abbrev Oracle (N : ℕ) := Fin N → Fin 3

-- !-- comment -- !--
-- Counting the oracle space: a function space `Fin N → Fin 3` has
-- `(card Fin 3) ^ (card Fin N) = 3 ^ N` elements; `simp` discharges the function-space
-- count directly.
-- !-- comment -- !--
/-- There are exactly `3 ^ N` three-valued oracles on `N` statements. -/
theorem oracle_card (N : ℕ) : Fintype.card (Oracle N) = 3 ^ N := by
  simp [Oracle]

-- !-- comment -- !--
-- The coverage obstruction, stated for an *arbitrary* alphabet size `a`: if a
-- surjection `P → (Fin N → Fin a)` existed, then `card P ≥ a ^ N`, contradicting the
-- hypothesis. Nothing about the number `3` is used.
-- !-- comment -- !--
/-- **The generic barrier.** For any answer alphabet of size `a`, a program space `P`
strictly smaller than the oracle space `a ^ N` cannot cover it: some oracle escapes
every compilation `f : P → (Fin N → Fin a)`. -/
theorem oracle_not_covered_generic {P : Type*} [Fintype P] {N a : ℕ}
    (f : P → (Fin N → Fin a)) (h : Fintype.card P < a ^ N) :
    ∃ g : Fin N → Fin a, ∀ p, f p ≠ g := by
  by_contra hc
  push_neg at hc
  have hsurj : Function.Surjective f := by
    intro g; obtain ⟨p, hp⟩ := hc g; exact ⟨p, hp⟩
  have := Fintype.card_le_of_surjective f hsurj
  rw [Fintype.card_fun, Fintype.card_fin, Fintype.card_fin] at this
  omega

-- !-- comment -- !--
-- The three-valued specialization is a one-line corollary of the generic barrier with
-- `a = 3`; this confirms that the "3" was never used by coverage.
-- !-- comment -- !--
/-- **The three-valued barrier.** A program space smaller than `3 ^ N` cannot name all
oracles: some three-valued oracle escapes every compilation. -/
theorem oracle_not_covered {P : Type*} [Fintype P] {N : ℕ}
    (f : P → Oracle N) (h : Fintype.card P < 3 ^ N) :
    ∃ g : Oracle N, ∀ p, f p ≠ g :=
  oracle_not_covered_generic f h

-- !-- comment -- !--
-- Growth lemma: `3 ^ N` is unbounded, so any fixed natural `b ^ k` is eventually
-- exceeded; `pow_unbounded_of_one_lt` with `1 < 3` gives the witness `N`.
-- !-- comment -- !--
/-- Every fixed program budget `b ^ k` is eventually outrun by the oracle count
`3 ^ N`. -/
theorem budget_gap_exists (b k : ℕ) : ∃ N, b ^ k < 3 ^ N :=
  pow_unbounded_of_one_lt (b ^ k) (by norm_num)

-- !-- comment -- !--
-- Information deficit of binary descriptions: `2 ^ N < 3 ^ N` for `N ≥ 1` by strict
-- monotonicity of `x ↦ x ^ N` in the base (with `N ≠ 0`). The boundary `N = 0` is
-- exactly where equality `1 = 1` defeats the strict inequality.
-- !-- comment -- !--
/-- Binary descriptions of length `N` are strictly too poor to name all three-valued
oracles: `2 ^ N < 3 ^ N` whenever `N ≥ 1`. -/
theorem binary_insufficient {N : ℕ} (hN : 1 ≤ N) : 2 ^ N < 3 ^ N :=
  Nat.pow_lt_pow_left (by norm_num) (by omega)

-- !-- comment -- !--
-- Exact law: dividing the two power towers gives a single geometric power by `div_pow`.
-- !-- comment -- !--
/-- The fraction of three-valued oracles reachable by length-`N` binary descriptions is
the exact geometric law `2 ^ N / 3 ^ N = (2 / 3) ^ N`. -/
theorem binary_fraction_eq (N : ℕ) : (2 : ℝ) ^ N / 3 ^ N = (2 / 3) ^ N := by
  rw [div_pow]

-- !-- comment -- !--
-- The geometric ratio `2/3 ∈ [0,1)` so its powers tend to `0` by the standard limit.
-- !-- comment -- !--
/-- The binary-reachable fraction vanishes geometrically. -/
theorem binary_fraction_tendsto_zero :
    Filter.Tendsto (fun N => (2 / 3 : ℝ) ^ N) Filter.atTop (𝓝 0) :=
  tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)

-- !-- comment -- !--
-- Rewriting `C / 3 ^ N = C * (1/3) ^ N` reduces to a constant times a vanishing
-- geometric sequence; the limit is `C * 0 = 0`.
-- !-- comment -- !--
/-- For any constant program budget `C`, the nameable fraction `C / 3 ^ N` tends to
`0`: a fixed description budget computes a vanishing share of all oracles. -/
theorem computable_fraction_tendsto_zero (C : ℝ) :
    Filter.Tendsto (fun N => C / 3 ^ N) Filter.atTop (𝓝 0) := by
  have h : Filter.Tendsto (fun N => C * (1 / 3 : ℝ) ^ N) Filter.atTop (𝓝 (C * 0)) :=
    Filter.Tendsto.const_mul C
      (tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num))
  rw [mul_zero] at h
  convert h using 2 with N
  rw [div_pow, one_pow]; ring

/-!
## Lab Notebook

-- !-- Lab Notebook -- !--

**Hypothesis.** The whole "three-valued oracles are not finitely computable" story is a
shadow of one cardinal inequality: `card P < card (oracle space)`. We conjectured the
number `3` is irrelevant to the *coverage* half and only matters for the *information*
half.

**Result.** Confirmed. `oracle_not_covered_generic` is proved for an arbitrary alphabet
size `a` (coverage), and `oracle_not_covered` is its one-line `a = 3` corollary. The
number `3` appears only in `binary_insufficient` (`2 ^ N < 3 ^ N`),
`binary_fraction_eq` (`(2/3) ^ N`), and the two limits — i.e. exclusively in the
information half. Eight results, each one or two lines.

**Insight.** Factoring an impossibility argument into a *coverage* obstruction (pure
pigeonhole / `Fintype.card_le_of_surjective`) and an *information* obstruction (base
comparison of powers) makes the coverage lemma reusable verbatim across domains: only
the codomain changes. This is the structural payoff — the core lemma `oracle_not_covered_generic`
is alphabet-parametric and hence domain-agnostic.

**Failure analysis.** Two friction points. (1) The binary deficit `2 ^ N < 3 ^ N` is
*false* at `N = 0` (`1 = 1`), so the hypothesis `1 ≤ N` is genuinely load-bearing — a
reminder that the information barrier has a boundary the coverage barrier does not.
(2) `omega` cannot reason about `(m + 1) % a` with a *variable* modulus `a`; the
diagonal construction (see `OracleBarrierExtensions`) therefore case-splits on
`m + 1 < a` vs `m + 1 = a` rather than leaning on `omega` for modular arithmetic.
-/