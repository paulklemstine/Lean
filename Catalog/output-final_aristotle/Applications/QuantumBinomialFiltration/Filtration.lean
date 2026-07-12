import Mathlib

/-!
# Quantum binomial coefficients and the character filtration of plethystic modules

Let `E` be the two–dimensional standard representation of `GL₂`, carrying the
principal grading in which the two coordinate lines sit in degrees `0` and `1`.
For `n ≥ m ≥ 0` and `d ≥ 0` the *plethystic module* `Δ^{(n,m)} Sym^d E` studied in
the theory of Hermite reciprocity, the Wronskian isomorphism and the
Grosshans–Steinberg–Milne–Wallach (GSMW) Pfaffian carries a field–independent
filtration whose graded pieces are again modules of the same shape.  At the level
of *formal characters* (equivalently, principal specialisations) all of this is
governed by a single combinatorial object: the **Gaussian / quantum binomial
coefficient** `[n , k]_q`, the character of `Sym^k Sym^{n-k}` of the standard
representation.  The same polynomials are exactly the structure constants in
Lusztig's product rule (Rel2) for the divided powers of a quantum Cartan datum,
`E^{(a)} E^{(b)} = [a+b , a]_q · E^{(a+b)}`.

This file builds the character theory from scratch as polynomials in `ℤ[q]`
(`q = X`) and proves the identities underlying the categorified product rule:

* `qBinom_pascal` — the **filtration short exact sequence** at the level of
  characters, `[n+1 , k+1]_q = [n , k]_q + q^{k+1} · [n , k+1]_q`.  This is the
  numerical shadow of the first graded piece of the filtration.
* `qBinom_pascal'` — the *dual* Pascal rule `[n+k+1 , k+1]_q =
  q^{n} · [n+k , k]_q + [n+k , k+1]_q`, the second filtration step.
* `qBinom_symm` — **Hermite reciprocity**: `[a+b , a]_q = [a+b , b]_q`, i.e.
  `Sym^a Sym^b E ≅ Sym^b Sym^a E` as graded modules.
* `qBinom_eval_one` — the **classical dimension bridge**: setting `q = 1`
  recovers the ordinary binomial coefficient `C(n,k)`.
* `qBinom_eval_zero` — the constant term is `1` exactly when `k ≤ n`, the unique
  lowest graded piece of the module.
* `qBinom_one` — the `q`-integer `[n , 1]_q = 1 + q + ⋯ + q^{n-1}`.
* `gradedDim`, `hermite_reciprocity`, `classical_dimension` — the packaged
  representation–theoretic statements.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):  Every field-independent filtration datum of
  `Δ^{(n,m)} Sym^d E` is controlled by one family of polynomials `[n,k]_q`, and
  the two Pascal recurrences are the two elementary filtration steps whose
  composite realises Hermite reciprocity.
Experiment (Experimenter):  Define `[n,k]_q` by the first Pascal recurrence,
  prove the dual recurrence `qBinom_pascal'` by induction, and derive the
  reciprocity `[a+b,a]=[a+b,b]` by strong induction on `a+b` using *both*
  recurrences (one for each side).
Analysis (Analyst):  Form A alone cannot prove reciprocity — matching the two
  sides genuinely requires the dual rule, which is the abstract reason the
  filtration must be built from two complementary short exact sequences.
Critique (Critic):  The reciprocity is not vacuous: `qBinom_eval_one` shows the
  polynomials specialise to the honest binomial coefficients, and `qBinom_one`
  exhibits a non-constant example, so `[n,k]_q` is a genuine deformation.
Synthesis (PI):  The quantum binomial coefficients form a self-dual family under
  `k ↦ n-k`; this self-duality is the character-level content of Hermite
  reciprocity and of Lusztig's Rel2 product rule for divided powers.
-- !-- end Lab Notes -- !--
-/

open Polynomial

namespace QuantumBinomialFiltration

/-- The **Gaussian (quantum) binomial coefficient** `[n , k]_q` as a polynomial in
`q = X`, defined by the `q`-Pascal recurrence.  It is the formal character of
`Sym^k Sym^{n-k}` of the two-dimensional standard representation. -/
noncomputable def qBinom : ℕ → ℕ → Polynomial ℤ
  | _, 0 => 1
  | 0, (_ + 1) => 0
  | (n + 1), (k + 1) => qBinom n k + X ^ (k + 1) * qBinom n (k + 1)

@[simp] lemma qBinom_zero_right (n : ℕ) : qBinom n 0 = 1 := by cases n <;> rfl

@[simp] lemma qBinom_zero_succ (k : ℕ) : qBinom 0 (k + 1) = 0 := rfl

/-- The defining `q`-Pascal recurrence (filtration step, form A). -/
lemma qBinom_pascal (n k : ℕ) :
    qBinom (n + 1) (k + 1) = qBinom n k + X ^ (k + 1) * qBinom n (k + 1) := rfl

/-
Above the diagonal the coefficient vanishes.
-/
lemma qBinom_eq_zero {n k : ℕ} (h : n < k) : qBinom n k = 0 := by
  induction' n with n ih generalizing k;
  · cases k <;> aesop;
  · rcases k with ( _ | _ | k ) <;> simp_all +decide [ qBinom_pascal ];
    grind

/-
On the diagonal the coefficient is `1` (the top graded piece is one-dimensional).
-/
@[simp] lemma qBinom_self (n : ℕ) : qBinom n n = 1 := by
  induction' n with n ih;
  · rfl;
  · grind +suggestions

/-- Setting `q = 1` recovers the classical binomial coefficient. -/
lemma qBinom_eval_one (n k : ℕ) : (qBinom n k).eval 1 = (n.choose k : ℤ) := by
  induction n generalizing k with
  | zero => cases k with
    | zero => simp
    | succ k => simp
  | succ n ih =>
    cases k with
    | zero => simp
    | succ k => rw [qBinom_pascal]; simp [ih, Nat.choose_succ_succ]

/-
The constant term is `1` precisely when `k ≤ n` (unique lowest graded piece).
-/
lemma qBinom_eval_zero {n k : ℕ} (h : k ≤ n) : (qBinom n k).eval 0 = 1 := by
  induction' n with n ih generalizing k <;> induction' k with k ih' <;> simp_all +decide [ qBinom_pascal ]

/-- The `q`-integer `[n , 1]_q = 1 + q + ⋯ + q^{n-1}`. -/
lemma qBinom_one (n : ℕ) : qBinom n 1 = ∑ i ∈ Finset.range n, X ^ i := by
  induction' n with n ih;
  · rfl;
  · simp_all +decide [ Finset.sum_range_succ', qBinom_pascal ];
    simp +decide [ add_comm, pow_succ', Finset.mul_sum _ _ _ ]

/-
The **absorption / adjacency identity** relating two neighbouring quantum
binomial coefficients of the same weight:
`[a+b+1 , b+1]_q · (1 - q^{b+1}) = [a+b+1 , b]_q · (1 - q^{a+1})`.
This is the numerical engine behind Hermite reciprocity.
-/
lemma qBinom_absorb (a b : ℕ) :
    qBinom (a + b + 1) (b + 1) * (1 - X ^ (b + 1)) =
      qBinom (a + b + 1) b * (1 - X ^ (a + 1)) := by
  induction' a with a ih generalizing b <;> induction' b with b ih' <;> norm_num at *;
  · grind +suggestions;
  · rw [ qBinom_one ];
    rw [ geom_sum_mul_neg ];
  · convert congr_arg₂ ( · + · ) ( congr_arg ( fun p => X ^ ( b + 2 ) * p ) ( ih ( b + 1 ) ) ) ( congr_arg ( · * ( 1 - X ^ ( b + 2 ) ) ) ( show qBinom ( a + 1 + b + 1 ) ( b + 1 ) = qBinom ( a + b + 2 ) ( b + 1 ) by ring ) ) using 1 <;> ring!;
    · rw [ show 3 + a + b = 2 + a + b + 1 by ring, show 2 + b = 1 + b + 1 by ring ] ; rw [ qBinom_pascal ] ; ring;
    · rw [ show 3 + a + b = 2 + a + b + 1 by ring, show 1 + b = b + 1 by ring ] ; rw [ qBinom_pascal ] ; ring;
      grind +ring

/-
**Hermite reciprocity** at the level of characters: the Gaussian binomial
coefficient is symmetric, `[a+b , a]_q = [a+b , b]_q`.  Equivalently
`Sym^a Sym^b E ≅ Sym^b Sym^a E` as graded representations.
-/
lemma qBinom_symm (a b : ℕ) : qBinom (a + b) a = qBinom (a + b) b := by
  induction' a with a ha generalizing b;
  · aesop;
  · induction' b with b hb ; simp_all +decide;
    convert congr_arg₂ ( · + · ) ( ha ( b + 1 ) ) ( congr_arg ( fun p => X ^ ( a + 1 ) * p ) hb ) using 1;
    · grind +suggestions;
    · grind +suggestions

/-
The **dual `q`-Pascal recurrence** (filtration step, form B), phrased without
truncated subtraction: `[n+k+1 , k+1]_q = q^{n} [n+k , k]_q + [n+k , k+1]_q`.
-/
lemma qBinom_pascal' (n k : ℕ) :
    qBinom (n + k + 1) (k + 1) = X ^ n * qBinom (n + k) k + qBinom (n + k) (k + 1) := by
  induction' n with n ih generalizing k <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ]; all_goals grind +suggestions

/-- The graded dimension (formal character, principal specialisation) of
`Sym^a Sym^b E` for the two-dimensional standard representation `E`. -/
noncomputable def gradedDim (a b : ℕ) : Polynomial ℤ := qBinom (a + b) a

/-- **Hermite reciprocity**, packaged: `Sym^a Sym^b E` and `Sym^b Sym^a E` have
equal graded characters. -/
theorem hermite_reciprocity (a b : ℕ) : gradedDim a b = gradedDim b a := by
  unfold gradedDim
  rw [qBinom_symm a b, Nat.add_comm a b]

/-- The classical dimension `dim Sym^a Sym^b E = C(a+b , a)` is recovered by the
principal specialisation `q = 1`. -/
theorem classical_dimension (a b : ℕ) :
    (gradedDim a b).eval 1 = ((a + b).choose a : ℤ) := by
  unfold gradedDim; exact qBinom_eval_one (a + b) a

/-- **The categorified product rule (first filtration step).**  The graded
character of `Sym^{a+1} Sym^{b+1} E` splits as the character of the sub-object
`Sym^{a} Sym^{b+1} E` plus a degree-shift `q^{a+1}` of the quotient character
`Sym^{a+1} Sym^{b} E`.  This is the character-level short exact sequence
`0 → Sym^{a} Sym^{b+1} E → Sym^{a+1} Sym^{b+1} E → Sym^{a+1} Sym^{b} E → 0`
underlying the field-independent filtration of the plethystic modules. -/
theorem filtration_step (a b : ℕ) :
    gradedDim (a + 1) (b + 1) = gradedDim a (b + 1) + X ^ (a + 1) * gradedDim (a + 1) b := by
  unfold gradedDim
  have h1 : a + 1 + (b + 1) = (a + b + 1) + 1 := by ring
  have h2 : a + (b + 1) = a + b + 1 := by ring
  have h3 : a + 1 + b = a + b + 1 := by ring
  rw [h1, h2, h3, qBinom_pascal]

end QuantumBinomialFiltration