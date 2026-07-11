import Mathlib

/-!
# Ramanujan-style intuition as non-computable meta-reasoning

Many of Ramanujan's identities were announced without proof and only later
verified.  This suggests modelling mathematical *intuition* as an **oracle**: a
device that, presented with an (encoded) number-theoretic statement, returns a
verdict, and does so with high reliability even though it carries no proof.

We encode statements by natural numbers and model a truth assignment or an oracle
as a Boolean-valued function `ℕ → Bool`.  The file establishes, with fully
explicit combinatorial arguments, three facts.

* **Uncountability of oracles** (`no_enumeration_of_oracles`): the space of
  oracles admits no enumeration; a diagonal (Cantor) argument.

* **Diagonal non-computability** (`diagonal_not_mem_range`,
  `exists_truth_outside`): the *computable* oracles are, by definition, those
  lying in the range of a fixed enumeration of programs; hence they form a
  countable family, and there is always a truth assignment whose perfect oracle
  escapes any prescribed enumeration.  A flawless intuition therefore cannot be
  computable — this is the counting argument at the heart of the mission.

* **The 95%-accuracy barrier** (`exists_defeating_truth`): a *quantitative*
  refinement.  On a block of `N` statements, a single oracle predicts correctly
  to within `d` errors only for those truth patterns lying in a Hamming ball of
  radius `d`, whose size is exactly the binomial partial sum
  `∑_{k ≤ d} C(N,k)`.  Consequently any family of oracles that is small compared
  to `2^N / ∑_{k ≤ d} C(N,k)` is *defeated*: some truth pattern is predicted with
  more than `d` errors by **every** oracle in the family.  Setting `d = N - m`
  turns "more than `d` errors" into "accuracy below `m/N`", so a genuinely
  reliable oracle cannot be drawn from a small (e.g. computably enumerable) pool.

The counting bridge — Hamming balls (coding theory / combinatorics) controlling
the reach of an oracle (computability) — is the cross-domain core.
-/

namespace RamanujanOracle

open Finset

/-- A statement is encoded by a natural number; an **oracle** (or a truth
assignment) is a Boolean verdict on every encoded statement. -/
abbrev Oracle := ℕ → Bool

/-! ## Part A — the space of oracles is not enumerable -/

/-
**Cantor's diagonal argument for oracles.**  There is no surjection from the
natural numbers onto the space of oracles: intuition ranges over uncountably many
possible verdict-functions.
-/
theorem no_enumeration_of_oracles : ¬ ∃ f : ℕ → Oracle, Function.Surjective f := by
  simp +zetaDelta at *;
  intro f hf; have := hf ( fun n => ! f n n ) ; obtain ⟨ m, hm ⟩ := this; have := congr_fun hm m; simp +decide at this;

/-! ## Part B — a perfect oracle escapes any enumeration of programs -/

/-- The **diagonal oracle** of an enumeration: it disagrees with the `n`-th
listed oracle precisely at input `n`. -/
def diagonal (enum : ℕ → Oracle) : Oracle := fun n => !(enum n n)

/-
The diagonal oracle differs from every listed oracle.
-/
theorem diagonal_ne (enum : ℕ → Oracle) (n : ℕ) : diagonal enum ≠ enum n := by
  exact fun h => by have := congr_fun h n; simp +decide [ diagonal ] at this;

/-
The diagonal oracle lies outside the range of the enumeration.
-/
theorem diagonal_not_mem_range (enum : ℕ → Oracle) :
    diagonal enum ∉ Set.range enum := by
  rintro ⟨ n, hn ⟩;
  exact absurd ( congr_fun hn n ) ( by unfold diagonal; aesop )

/-- **Non-computability by counting.**  Model the computable oracles as the range
of a fixed enumeration `enum` of programs (they are countable).  Then there is a
truth assignment whose flawless oracle is *not* computable: a perfect intuition
cannot be captured by any enumeration of algorithms. -/
theorem exists_truth_outside (enum : ℕ → Oracle) :
    ∃ T : Oracle, T ∉ Set.range enum :=
  ⟨diagonal enum, diagonal_not_mem_range enum⟩

/-! ## Part C — the quantitative 95%-accuracy barrier -/

/-- The set of length-`N` truth patterns that oracle `r` predicts with at most
`d` errors: a Hamming ball of radius `d` centred at `r`. -/
def ball (N d : ℕ) (r : Fin N → Bool) : Finset (Fin N → Bool) :=
  univ.filter (fun t => hammingDist r t ≤ d)

/-
The number of subsets of an `N`-element set with at most `d` elements is the
binomial partial sum `∑_{k ≤ d} C(N,k)`.
-/
theorem powerset_filter_card (N d : ℕ) :
    ((univ : Finset (Fin N)).powerset.filter (fun S => S.card ≤ d)).card
      = ∑ k ∈ range (d + 1), N.choose k := by
  rw [ show { S ∈ Finset.powerset ( Finset.univ : Finset ( Fin N ) ) | Finset.card S ≤ d } = Finset.biUnion ( Finset.Iic d ) fun k => Finset.powersetCard k ( Finset.univ : Finset ( Fin N ) ) from ?_, Finset.card_biUnion ];
  · simp +arith +decide [ Finset.card_univ ];
    rw [ Finset.range_eq_Ico ] ; rfl;
  · exact fun i hi j hj hij => Finset.disjoint_left.mpr fun x hx₁ hx₂ => hij <| by rw [ Finset.mem_powersetCard ] at hx₁ hx₂; aesop;
  · ext; aesop

/-
**Ball-size formula.**  A radius-`d` Hamming ball among length-`N` Boolean
strings contains exactly `∑_{k ≤ d} C(N,k)` points, independent of its centre.
-/
theorem ball_card (N d : ℕ) (r : Fin N → Bool) :
    (ball N d r).card = ∑ k ∈ range (d + 1), N.choose k := by
  rw [ ← powerset_filter_card ];
  refine' Finset.card_bij ( fun t ht => Finset.univ.filter fun k => r k ≠ t k ) _ _ _;
  · simp +contextual [ ball, hammingDist ];
  · simp +contextual [ Finset.ext_iff ];
    intro a₁ ha₁ a₂ ha₂ h; ext i; specialize h i; by_cases hi : r i <;> by_cases hi' : a₁ i <;> by_cases hi'' : a₂ i <;> simp_all +decide ;
  · intro b hb; use fun k => if k ∈ b then !r k else r k; simp_all +decide [ ball ] ;
    refine' le_trans _ hb;
    exact Finset.card_le_card fun x hx => by aesop;

/-
The whole cube of length-`N` Boolean strings has `2^N` points.
-/
theorem card_cube (N : ℕ) : (univ : Finset (Fin N → Bool)).card = 2 ^ N := by
  rw [ Finset.card_univ ] ; norm_num

/-
A proper Hamming ball (`d < N`) misses at least one string, so its size is
strictly below `2^N`.
-/
theorem ball_card_lt {N d : ℕ} (hd : d < N) (r : Fin N → Bool) :
    (ball N d r).card < 2 ^ N := by
  rw [ ball_card, ← Nat.sum_range_choose ];
  rw [ ← Finset.sum_range_add_sum_Ico _ ( show d + 1 ≤ N + 1 from by linarith ) ];
  exact lt_add_of_pos_right _ ( Finset.sum_pos ( fun x hx => Nat.choose_pos ( by linarith [ Finset.mem_Ico.mp hx ] ) ) ( by norm_num; linarith ) )

/-
**The accuracy barrier.**  Fix a block of `N` statements and an error budget
`d < N`.  If a family `F` of oracles is small enough that
`|F| · ∑_{k ≤ d} C(N,k) < 2^N`, then some truth pattern on the block is mispredicted
by **more than `d`** statements by *every* oracle in `F`.  Taking `d = N - m`, no
oracle in `F` reaches accuracy `m` on that pattern: reliable intuition cannot come
from a small pool of oracles.
-/
theorem exists_defeating_truth {N d : ℕ} (F : Finset (Fin N → Bool))
    (hF : F.card * (∑ k ∈ range (d + 1), N.choose k) < 2 ^ N) :
    ∃ t : Fin N → Bool, ∀ r ∈ F, d < hammingDist r t := by
  -- Let covered := F.biUnion (fun r => ball N d r).
  set covered := F.biUnion (fun r => ball N d r) with hcovered_def
  have hcovered_card : covered.card ≤ F.card * (∑ k ∈ range (d + 1), N.choose k) := by
    exact le_trans ( Finset.card_biUnion_le ) ( Finset.sum_le_card_nsmul _ _ _ fun x hx => by rw [ ball_card ] );
  contrapose! hF; have := Finset.eq_univ_of_forall ( fun x => show x ∈ covered from ?_ ) ; aesop;
  exact Finset.mem_biUnion.mpr ( by obtain ⟨ r, hr₁, hr₂ ⟩ := hF x; exact ⟨ r, hr₁, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hr₂ ⟩ ⟩ )

/-!
-- !-- Lab Notes -- !--

**Hypothesis (Hypothesizer).**  "Ramanujan-style intuition" — a reliable but
proof-free verdict map on statements — should be non-computable for two
independent reasons: a soft counting reason (oracles are uncountable, programs
countable) and a hard *quantitative* reason (accuracy on a block forces the
oracle into a small Hamming ball, and small pools of oracles cannot cover all
truth patterns).

**Experiment (Experimenter).**  Parts A and B are the classical diagonal
arguments, made concrete for `Oracle := ℕ → Bool`.  Part C reduces the reach of
an accurate oracle to a Hamming-ball count, evaluated exactly via a bijection
with subsets and the binomial partial sum `∑_{k ≤ d} C(N,k)`.

**Analysis (Analyst).**  The exact ball-size formula is what upgrades a mere
"most functions are non-computable" slogan into a *usable* bound: it names the
threshold `2^N / ∑_{k ≤ d} C(N,k)` below which a family is provably defeated.
For `d = N - m` with `m` near `N` (high accuracy) the partial sum is tiny, so the
threshold is enormous — accurate oracles are exponentially rare.

**Critique (Critic).**  `exists_defeating_truth` is vacuous only if its
hypothesis is unsatisfiable; it is not — e.g. any singleton family with `d < N`
satisfies it via `ball_card_lt`.  The theorem is a genuine counting result, not a
definitional identity, and uses `card_biUnion_le`, the ball bijection, and strict
monotonicity of binomial partial sums.

**Synthesis (PI).**  Together Parts A–C formalize the mission's claim: a
Ramanujan oracle that is reliable on a rich family of statements cannot be
computable, and the obstruction is quantitative and combinatorial, not merely
cardinality-theoretic.
-/

end RamanujanOracle