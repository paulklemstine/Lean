import Physics.QuantumPythagoreanWalk.Tree

/-!
# Quantum-Pythagorean-Walk — II. The walk, its amplitudes and its energy spectrum

A *walk word* is a list `w : List (Fin 3)` of coin outcomes; `walk w` is the Berggren node
it reaches from the root `(3,4,5)`.  The uniform (Hadamard-like) coin gives every word of
length `n` the amplitude `3^{-n/2}`, so that the state at time `n` is normalised
(`amplitude_normalization`).

The "energy" of a node relative to a target `N` is `energy N t = t.c % N`; the spectrum
minima (`energy = 0`) are exactly the *resonant* nodes `N ∣ c` (`resonant_iff_energy_eq_zero`).

Main results:

* `walk_isPPT` — the walk stays inside the primitive Pythagorean triples;
* `hyp_walk_le`, `hyp_walk_ge` — two-sided depth/hypotenuse estimates
  `8·|w| + 5 ≤ c(w) ≤ 5·7^{|w|}`;
* `amplitude_normalization` — the depth-`n` state is a unit vector;
* `coherent_resonance_amplitude_sq` — constructive interference on the resonance set gives
  a coherent probability equal to `|R| ·` (classical probability): the interference gain is
  exactly the number of resonant branches;
* `resonanceSet_eq_empty_of_shallow` — there is a *critical depth*: no resonance can occur
  before depth `log₇(N/5)`, whatever the coin.
-/

namespace QuantumPythagoreanWalk

open Node

/-- The node reached by the walk word `w` (read right to left) from the root. -/
def walk : List (Fin 3) → Node
  | [] => root
  | i :: w => Node.branch i (walk w)

@[simp] lemma walk_nil : walk [] = root := rfl
@[simp] lemma walk_cons (i : Fin 3) (w : List (Fin 3)) :
    walk (i :: w) = Node.branch i (walk w) := rfl

/-- The walk never leaves the set of primitive Pythagorean triples. -/
theorem walk_isPPT (w : List (Fin 3)) : (walk w).IsPPT := by
  induction w with
  | nil => exact root_isPPT
  | cons i w ih => exact ih.branch i

/-- Upper bound: the hypotenuse grows by a factor at most `7` per step. -/
theorem hyp_walk_le (w : List (Fin 3)) : (walk w).c ≤ 5 * 7 ^ w.length := by
  induction w with
  | nil => simp [root]
  | cons i w ih =>
      have h := hyp_branch_le_seven_mul (walk_isPPT w) i
      have : (7 : ℤ) * (walk w).c ≤ 7 * (5 * 7 ^ w.length) := by omega
      calc (walk (i :: w)).c ≤ 7 * (walk w).c := h
        _ ≤ 7 * (5 * 7 ^ w.length) := this
        _ = 5 * 7 ^ (i :: w).length := by simp [List.length_cons, pow_succ]; ring

/-- Lower bound: the hypotenuse grows by at least `8` per step. -/
theorem hyp_walk_ge (w : List (Fin 3)) : 8 * w.length + 5 ≤ (walk w).c := by
  induction w with
  | nil => simp [root]
  | cons i w ih =>
      have h := hyp_add_eight_le_branch (walk_isPPT w) i
      have hl : ((i :: w).length : ℤ) = w.length + 1 := by simp
      rw [hl]
      have : (walk (i :: w)).c ≥ (walk w).c + 8 := h
      omega

theorem hyp_walk_pos (w : List (Fin 3)) : 0 < (walk w).c := (walk_isPPT w).pos_c

/-! ### Energy spectrum -/

/-- The energy of a node relative to the target `N`: the residue of the hypotenuse. -/
def energy (N : ℤ) (t : Node) : ℤ := t.c % N

/-- A node is *resonant* for `N` when `N` divides its hypotenuse. -/
def Resonant (N : ℤ) (t : Node) : Prop := N ∣ t.c

theorem energy_nonneg {N : ℤ} (hN : 0 < N) (t : Node) : 0 ≤ energy N t :=
  Int.emod_nonneg _ (ne_of_gt hN)

theorem energy_lt {N : ℤ} (hN : 0 < N) (t : Node) : energy N t < N :=
  Int.emod_lt_of_pos _ hN

/-- The minima of the energy spectrum are exactly the resonant nodes. -/
theorem resonant_iff_energy_eq_zero (N : ℤ) (t : Node) : Resonant N t ↔ energy N t = 0 :=
  ⟨fun h => Int.emod_eq_zero_of_dvd h, fun h => Int.dvd_of_emod_eq_zero h⟩

/-! ### Amplitudes of the uniform quantum walk -/

/-- Amplitude of one branch of length `n` under the uniform coin. -/
noncomputable def amplitude (n : ℕ) : ℝ := (Real.sqrt 3)⁻¹ ^ n

theorem amplitude_sq (n : ℕ) : amplitude n ^ 2 = (3 : ℝ)⁻¹ ^ n := by
  unfold amplitude
  rw [← pow_mul, mul_comm, pow_mul]
  congr 1
  rw [← Real.sqrt_inv, Real.sq_sqrt (by norm_num)]

theorem amplitude_pos (n : ℕ) : 0 < amplitude n := by
  unfold amplitude
  positivity

/-- The depth-`n` state of the uniform walk is a unit vector: total probability `1`. -/
theorem amplitude_normalization (n : ℕ) :
    ∑ _w : Fin n → Fin 3, amplitude n ^ 2 = 1 := by
  rw [Finset.sum_const, Finset.card_univ, amplitude_sq]
  have hcard : (Fintype.card (Fin n → Fin 3) : ℕ) = 3 ^ n := by
    simp
  rw [hcard]
  rw [nsmul_eq_mul]
  push_cast
  rw [inv_pow, mul_inv_cancel₀ (by positivity)]

/-! ### The resonance subspace -/

/-- The word associated with a coin history `w : Fin n → Fin 3`. -/
def wordOf {n : ℕ} (w : Fin n → Fin 3) : List (Fin 3) := List.ofFn w

@[simp] theorem length_wordOf {n : ℕ} (w : Fin n → Fin 3) : (wordOf w).length = n := by
  simp [wordOf]

/-- The set of depth-`n` coin histories whose endpoint is resonant for `N`. -/
noncomputable def resonanceSet (N : ℤ) (n : ℕ) : Finset (Fin n → Fin 3) :=
  Finset.univ.filter (fun w => N ∣ (walk (wordOf w)).c)

/-- Classical (incoherent) probability that a depth-`n` walk ends on a resonance. -/
noncomputable def resonanceProb (N : ℤ) (n : ℕ) : ℝ :=
  (resonanceSet N n).card * (3 : ℝ)⁻¹ ^ n

/-- Coherent amplitude of the resonance subspace: all resonant branches add in phase. -/
noncomputable def coherentAmplitude (N : ℤ) (n : ℕ) : ℝ :=
  (resonanceSet N n).card * amplitude n

theorem resonanceProb_nonneg (N : ℤ) (n : ℕ) : 0 ≤ resonanceProb N n := by
  unfold resonanceProb; positivity

theorem card_resonanceSet_le (N : ℤ) (n : ℕ) : (resonanceSet N n).card ≤ 3 ^ n := by
  have := Finset.card_filter_le (Finset.univ : Finset (Fin n → Fin 3))
    (fun w => N ∣ (walk (wordOf w)).c)
  simpa [resonanceSet, Finset.card_univ, Fintype.card_fun] using this

theorem resonanceProb_le_one (N : ℤ) (n : ℕ) : resonanceProb N n ≤ 1 := by
  unfold resonanceProb
  have h : ((resonanceSet N n).card : ℝ) ≤ (3 : ℝ) ^ n := by
    exact_mod_cast card_resonanceSet_le N n
  calc ((resonanceSet N n).card : ℝ) * (3 : ℝ)⁻¹ ^ n
      ≤ (3 : ℝ) ^ n * (3 : ℝ)⁻¹ ^ n := by
        have : (0 : ℝ) < (3 : ℝ)⁻¹ ^ n := by positivity
        exact mul_le_mul_of_nonneg_right h (le_of_lt this)
    _ = 1 := by rw [inv_pow, mul_inv_cancel₀ (by positivity)]

/-- **Constructive interference.**  Squaring the coherent amplitude of the resonance
subspace yields the classical resonance probability multiplied by the number of resonant
branches: interference boosts the resonance signal by exactly the resonance multiplicity. -/
theorem coherent_resonance_amplitude_sq (N : ℤ) (n : ℕ) :
    coherentAmplitude N n ^ 2 = (resonanceSet N n).card * resonanceProb N n := by
  unfold coherentAmplitude resonanceProb
  rw [mul_pow, amplitude_sq]
  ring

/-- **Critical depth.**  A walk of length `n` cannot reach any resonance for a target `N`
exceeding `5·7ⁿ`: the resonance subspace is empty below the critical depth. -/
theorem resonanceSet_eq_empty_of_shallow {N : ℤ} (hN : 5 * 7 ^ n < N) :
    resonanceSet N n = ∅ := by
  ext w
  simp only [resonanceSet, Finset.mem_filter, Finset.mem_univ, true_and,
    Finset.notMem_empty, iff_false]
  intro hdvd
  have hpos := hyp_walk_pos (wordOf w)
  have hle : (walk (wordOf w)).c ≤ 5 * 7 ^ n := by
    have := hyp_walk_le (wordOf w)
    rwa [length_wordOf] at this
  have hge : N ≤ (walk (wordOf w)).c := Int.le_of_dvd hpos hdvd
  omega

/-- Consequently the resonance probability vanishes identically below the critical depth. -/
theorem resonanceProb_eq_zero_of_shallow {N : ℤ} (hN : 5 * 7 ^ n < N) :
    resonanceProb N n = 0 := by
  unfold resonanceProb
  rw [resonanceSet_eq_empty_of_shallow hN]
  simp

end QuantumPythagoreanWalk