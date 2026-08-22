import Mathlib

/-!
# Exact information-theoretic laws for finite two-observable count tables

This file develops, from scratch and in full generality, the finite information theory
needed to state and prove *exact* channel identities for arithmetic observables
(Frobenius splitting types, residue classes, quadratic characters).  Everything is
phrased for a **count table**

  `n : A → B → ℕ`,

i.e. the joint occupation numbers of two finite observables `X` (values in `A`) and
`Y` (values in `B`).  Entropies are Shannon entropies in bits, exactly as in the
catalog's `CyclicType.Hlist`, but organised as a joint distribution so that mutual
information is available.

Main results.

* `S3Channel.Imut_eq_HA_of_det` — *determinism law*: if `X` is a function of `Y`
  (the table is supported on the graph of `g : B → A`) then `I(X;Y) = H(X)`.
* `S3Channel.HA_eq_one_of_balanced_two` — a balanced binary observable has `H = 1` bit.
* `S3Channel.Imut_eq_one_of_character` — the **character channel law**: if the table
  is the "character-coupled" table
  `n a b = if χ a = g b then m b else 0`
  with `χ : A → Bool` splitting `A` into two fibres of equal size `k > 0` and
  `g : B → Bool` splitting the weight `m` into two halves of equal mass `M₂ > 0`,
  then `I(X;Y) = 1` *exactly*, no matter what `A`, `B`, `k` and `m` are.

The last theorem is the universal statement behind the "three fields, one answer"
phenomenon: the information a residue observable shares with the Frobenius splitting
type of an `S₃`-cubic is exactly one bit — the bit carried by the sign character —
independently of the field, of the modulus, and of the shape of the splitting-type
distribution.
-/

namespace S3Channel

open scoped BigOperators
open Finset

/-! ## The surprisal term -/

/-- The entropy contribution `-x log₂ x` of a single probability `x`.
Since `Real.logb 2 0 = 0`, the value at `0` is `0` with no case split needed. -/
noncomputable def sur (x : ℝ) : ℝ := -(x * Real.logb 2 x)

@[simp] lemma sur_zero : sur 0 = 0 := by simp [sur]

/-- Scaling law for the surprisal: `k · sur (x/k) = sur x + x·log₂ k` for `k > 0`. -/
lemma sur_div (x k : ℝ) (hk : 0 < k) :
    k * sur (x / k) = sur x + x * Real.logb 2 k := by
  rcases eq_or_ne x 0 with hx | hx
  · simp [sur, hx]
  · have hk' : k ≠ 0 := ne_of_gt hk
    have h : Real.logb 2 (x / k) = Real.logb 2 x - Real.logb 2 k := Real.logb_div hx hk'
    simp only [sur, h]
    field_simp
    ring

/-- The surprisal of a uniform probability `1/c` with `c > 0`. -/
lemma sur_inv (c : ℝ) (hc : 0 < c) : c * sur (1 / c) = Real.logb 2 c := by
  simpa [sur, Real.logb_one] using sur_div 1 c hc

/-! ## Count tables and their entropies -/

variable {A B : Type*} [Fintype A] [Fintype B]

/-- Total number of observations in a joint count table. -/
def total (n : A → B → ℕ) : ℕ := ∑ a, ∑ b, n a b

/-- The `A`-marginal counts. -/
def margA (n : A → B → ℕ) (a : A) : ℕ := ∑ b, n a b

/-- The `B`-marginal counts. -/
def margB (n : A → B → ℕ) (b : B) : ℕ := ∑ a, n a b

/-- Joint Shannon entropy (bits) of the normalised table. -/
noncomputable def Hjoint (n : A → B → ℕ) : ℝ :=
  ∑ a, ∑ b, sur ((n a b : ℝ) / (total n : ℝ))

/-- Entropy of the first observable. -/
noncomputable def HA (n : A → B → ℕ) : ℝ := ∑ a, sur ((margA n a : ℝ) / (total n : ℝ))

/-- Entropy of the second observable. -/
noncomputable def HB (n : A → B → ℕ) : ℝ := ∑ b, sur ((margB n b : ℝ) / (total n : ℝ))

/-- Mutual information `I(X;Y) = H(X) + H(Y) - H(X,Y)` in bits. -/
noncomputable def Imut (n : A → B → ℕ) : ℝ := HA n + HB n - Hjoint n

lemma total_eq_sum_margB (n : A → B → ℕ) : total n = ∑ b, margB n b := by
  simpa [total, margB] using Finset.sum_comm (s := (univ : Finset A)) (t := (univ : Finset B))
    (f := fun a b => n a b)

/-! ## The determinism law -/

omit [Fintype B] in
/-- If the joint table vanishes off the graph of `g : B → A`, the `B`-marginal is the
value on the graph. -/
lemma margB_eq_of_det (n : A → B → ℕ) (g : B → A)
    (hdet : ∀ a b, a ≠ g b → n a b = 0) (b : B) : margB n b = n (g b) b := by
  refine Finset.sum_eq_single (g b) ?_ ?_
  · intro a _ ha; exact hdet a b ha
  · intro h; exact absurd (mem_univ (g b)) h

/-- **Determinism law.**  If the first observable is a function `g` of the second — i.e.
the joint table vanishes off the graph of `g` — then the joint entropy collapses to the
entropy of the second observable. -/
theorem Hjoint_eq_HB_of_det (n : A → B → ℕ) (g : B → A)
    (hdet : ∀ a b, a ≠ g b → n a b = 0) : Hjoint n = HB n := by
  have hmarg := margB_eq_of_det n g hdet
  calc Hjoint n = ∑ b, ∑ a, sur ((n a b : ℝ) / (total n : ℝ)) := by
        simpa [Hjoint] using Finset.sum_comm (s := (univ : Finset A)) (t := (univ : Finset B))
          (f := fun a b => sur ((n a b : ℝ) / (total n : ℝ)))
    _ = ∑ b, sur ((n (g b) b : ℝ) / (total n : ℝ)) := by
        refine Finset.sum_congr rfl (fun b _ => ?_)
        refine Finset.sum_eq_single (g b) ?_ ?_
        · intro a _ ha; simp [hdet a b ha]
        · intro h; exact absurd (mem_univ (g b)) h
    _ = HB n := by
        unfold HB
        exact Finset.sum_congr rfl (fun b _ => by rw [hmarg b])

/-- **Determinism law, mutual-information form.** If `X = g(Y)` then `I(X;Y) = H(X)`:
the channel `Y → X` is noiseless, so it transmits exactly the entropy of `X`. -/
theorem Imut_eq_HA_of_det (n : A → B → ℕ) (g : B → A)
    (hdet : ∀ a b, a ≠ g b → n a b = 0) : Imut n = HA n := by
  have h := Hjoint_eq_HB_of_det n g hdet
  simp [Imut, h]

/-! ## Balanced binary observables -/

/-- A binary observable whose two marginals are exactly half of the total carries
exactly one bit of entropy. -/
theorem HA_eq_one_of_balanced_two (n : A → B → ℕ) (hcard : Fintype.card A = 2)
    (hbal : ∀ a, ((margA n a : ℝ)) / (total n : ℝ) = 1 / 2) : HA n = 1 := by
  have hsum : HA n = ∑ _a : A, sur (1 / 2 : ℝ) := by
    refine Finset.sum_congr rfl (fun a _ => ?_)
    rw [hbal a]
  have h2 : (2 : ℝ) * sur (1 / 2 : ℝ) = 1 := by
    rw [sur_inv 2 (by norm_num)]; simp
  rw [hsum, Finset.sum_const, Finset.card_univ, hcard]
  simpa [two_nsmul, two_mul] using h2

/-! ## The character channel law

The central structural theorem.  We consider a table coupling an arbitrary observable
`X` on `A` with an arbitrary observable `Y` on `B` **through a single bit**: a Boolean
character `χ` on `A` and a Boolean function `g` on `B`, with the joint counts

  `n a b = if χ a = g b then m b else 0`.

If `χ` is balanced (both fibres of size `k`) and `g` splits the weight `m` into two
equal halves `M₂`, then the mutual information is exactly one bit, whatever the sizes
of `A`, `B` and the profile `m`.
-/

section Character

variable (n : A → B → ℕ) (chi : A → Bool) (g : B → Bool) (m : B → ℕ) (k M2 : ℕ)

/-- The `A`-side is split in half by the character. -/
lemma card_eq_two_mul_of_balanced (hk : ∀ c : Bool, (univ.filter (fun a => chi a = c)).card = k) :
    Fintype.card A = 2 * k := by
  have h := Finset.card_filter_add_card_filter_not
    (s := (univ : Finset A)) (p := fun a => chi a = true)
  have h1 : (univ.filter (fun a => chi a = true)).card = k := hk true
  have h2 : (univ.filter (fun a => ¬ (chi a = true))).card = k := by
    have : (univ.filter (fun a => ¬ (chi a = true))) = univ.filter (fun a => chi a = false) := by
      refine Finset.filter_congr (fun a _ => ?_)
      simp [Bool.not_eq_true]
    rw [this]; exact hk false
  rw [h1, h2] at h
  simpa [Finset.card_univ, two_mul] using h.symm

/-- The total weight is twice the half-weight. -/
lemma sum_m_eq (hM : ∀ c : Bool, ∑ b ∈ univ.filter (fun b => g b = c), m b = M2) :
    ∑ b, m b = 2 * M2 := by
  have h := Finset.sum_filter_add_sum_filter_not (univ : Finset B) (fun b => g b = true) m
  have h2 : ∑ b ∈ univ.filter (fun b => ¬ (g b = true)), m b = M2 := by
    have : (univ.filter (fun b => ¬ (g b = true))) = univ.filter (fun b => g b = false) := by
      refine Finset.filter_congr (fun b _ => ?_)
      simp [Bool.not_eq_true]
    rw [this]; exact hM false
  rw [hM true, h2] at h
  omega

variable {n chi g m k M2}

omit [Fintype B] in
/-- The `B`-marginal of the character-coupled table. -/
lemma margB_character (hn : ∀ a b, n a b = if chi a = g b then m b else 0)
    (hk : ∀ c : Bool, (univ.filter (fun a => chi a = c)).card = k) (b : B) :
    margB n b = k * m b := by
  have : margB n b = ∑ a ∈ univ.filter (fun a => chi a = g b), m b := by
    rw [Finset.sum_filter]
    exact Finset.sum_congr rfl (fun a _ => hn a b)
  rw [this, Finset.sum_const, hk (g b), smul_eq_mul]

omit [Fintype A] in
/-- The `A`-marginal of the character-coupled table. -/
lemma margA_character (hn : ∀ a b, n a b = if chi a = g b then m b else 0)
    (hM : ∀ c : Bool, ∑ b ∈ univ.filter (fun b => g b = c), m b = M2) (a : A) :
    margA n a = M2 := by
  have h1 : margA n a = ∑ b ∈ univ.filter (fun b => chi a = g b), m b := by
    rw [Finset.sum_filter]
    exact Finset.sum_congr rfl (fun b _ => hn a b)
  have h2 : (univ.filter (fun b => chi a = g b)) = univ.filter (fun b => g b = chi a) := by
    refine Finset.filter_congr (fun b _ => ?_)
    simp [eq_comm]
  rw [h1, h2, hM (chi a)]

/-- The total count of the character-coupled table. -/
lemma total_character (hn : ∀ a b, n a b = if chi a = g b then m b else 0)
    (hk : ∀ c : Bool, (univ.filter (fun a => chi a = c)).card = k)
    (hM : ∀ c : Bool, ∑ b ∈ univ.filter (fun b => g b = c), m b = M2) :
    total n = k * (2 * M2) := by
  rw [total_eq_sum_margB]
  have : ∑ b, margB n b = ∑ b, k * m b :=
    Finset.sum_congr rfl (fun b _ => margB_character hn hk b)
  rw [this, ← Finset.mul_sum, sum_m_eq g m M2 hM]

/-- **Character channel law.**  For a table in which the only coupling between the two
observables is a balanced Boolean character, the mutual information is exactly `1` bit. -/
theorem Imut_eq_one_of_character
    (hn : ∀ a b, n a b = if chi a = g b then m b else 0)
    (hk : ∀ c : Bool, (univ.filter (fun a => chi a = c)).card = k) (hk0 : 0 < k)
    (hM : ∀ c : Bool, ∑ b ∈ univ.filter (fun b => g b = c), m b = M2) (hM0 : 0 < M2) :
    Imut n = 1 := by
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk0
  have hM2R : (0 : ℝ) < (M2 : ℝ) := by exact_mod_cast hM0
  have htot : total n = k * (2 * M2) := total_character hn hk hM
  have hNR : ((total n : ℕ) : ℝ) = (k : ℝ) * (2 * (M2 : ℝ)) := by
    rw [htot]; push_cast; ring
  have hNpos : (0 : ℝ) < ((total n : ℕ) : ℝ) := by rw [hNR]; positivity
  -- the `A`-entropy: `A` is uniform of size `2k`
  have hHA : HA n = Real.logb 2 (2 * (k : ℝ)) := by
    have hbal : ∀ a : A, ((margA n a : ℕ) : ℝ) / ((total n : ℕ) : ℝ) = 1 / (2 * (k : ℝ)) := by
      intro a
      rw [margA_character hn hM a, hNR]
      field_simp
    have hsum : HA n = ∑ _a : A, sur (1 / (2 * (k : ℝ))) :=
      Finset.sum_congr rfl (fun a _ => by rw [hbal a])
    rw [hsum, Finset.sum_const, Finset.card_univ, card_eq_two_mul_of_balanced chi k hk,
      nsmul_eq_mul]
    have := sur_inv (2 * (k : ℝ)) (by positivity)
    push_cast
    rw [← this]
  -- the joint entropy: `HB` plus `log₂ k`
  have hHjoint : Hjoint n = HB n + Real.logb 2 (k : ℝ) := by
    have hswap : Hjoint n = ∑ b, ∑ a, sur ((n a b : ℝ) / ((total n : ℕ) : ℝ)) := by
      simpa [Hjoint] using Finset.sum_comm (s := (univ : Finset A)) (t := (univ : Finset B))
        (f := fun a b => sur ((n a b : ℝ) / ((total n : ℕ) : ℝ)))
    have hinner : ∀ b : B, ∑ a, sur ((n a b : ℝ) / ((total n : ℕ) : ℝ))
        = (k : ℝ) * sur (((m b : ℝ) / (2 * (M2 : ℝ))) / (k : ℝ)) := by
      intro b
      have hval : ∀ a : A, sur ((n a b : ℝ) / ((total n : ℕ) : ℝ))
          = if chi a = g b then sur (((m b : ℝ) / (2 * (M2 : ℝ))) / (k : ℝ)) else 0 := by
        intro a
        by_cases h : chi a = g b
        · have : ((n a b : ℕ) : ℝ) = (m b : ℝ) := by rw [hn a b, if_pos h]
          rw [this, hNR, if_pos h]
          congr 1
          field_simp
        · rw [hn a b, if_neg h, if_neg h]
          simp
      calc ∑ a, sur ((n a b : ℝ) / ((total n : ℕ) : ℝ))
          = ∑ a, (if chi a = g b then sur (((m b : ℝ) / (2 * (M2 : ℝ))) / (k : ℝ)) else 0) :=
            Finset.sum_congr rfl (fun a _ => hval a)
        _ = ∑ _a ∈ univ.filter (fun a => chi a = g b),
              sur (((m b : ℝ) / (2 * (M2 : ℝ))) / (k : ℝ)) := (Finset.sum_filter _ _).symm
        _ = (k : ℝ) * sur (((m b : ℝ) / (2 * (M2 : ℝ))) / (k : ℝ)) := by
            rw [Finset.sum_const, hk (g b), nsmul_eq_mul]
    have hHBval : ∀ b : B, sur ((margB n b : ℝ) / ((total n : ℕ) : ℝ))
        = sur ((m b : ℝ) / (2 * (M2 : ℝ))) := by
      intro b
      rw [margB_character hn hk b, hNR]
      congr 1
      push_cast
      field_simp
    have hsumratio : ∑ b, ((m b : ℝ) / (2 * (M2 : ℝ))) = 1 := by
      rw [← Finset.sum_div]
      have : ((∑ b, m b : ℕ) : ℝ) = 2 * (M2 : ℝ) := by
        rw [sum_m_eq g m M2 hM]; push_cast; ring
      push_cast at this ⊢
      rw [this]
      field_simp
    calc Hjoint n = ∑ b, (k : ℝ) * sur (((m b : ℝ) / (2 * (M2 : ℝ))) / (k : ℝ)) := by
          rw [hswap]; exact Finset.sum_congr rfl (fun b _ => hinner b)
      _ = ∑ b, (sur ((m b : ℝ) / (2 * (M2 : ℝ)))
            + ((m b : ℝ) / (2 * (M2 : ℝ))) * Real.logb 2 (k : ℝ)) :=
          Finset.sum_congr rfl (fun b _ => sur_div _ _ hkR)
      _ = (∑ b, sur ((m b : ℝ) / (2 * (M2 : ℝ))))
            + (∑ b, ((m b : ℝ) / (2 * (M2 : ℝ)))) * Real.logb 2 (k : ℝ) := by
          rw [Finset.sum_add_distrib, Finset.sum_mul]
      _ = HB n + Real.logb 2 (k : ℝ) := by
          rw [hsumratio, one_mul]
          congr 1
          exact (Finset.sum_congr rfl (fun b _ => hHBval b)).symm
  -- assemble
  have hlog : Real.logb 2 (2 * (k : ℝ)) = 1 + Real.logb 2 (k : ℝ) := by
    rw [Real.logb_mul (by norm_num) (ne_of_gt hkR)]
    simp
  rw [Imut, hHA, hHjoint, hlog]
  ring

end Character

end S3Channel