import Mathlib
import Shared.GraphTheory.FractalTruthMetric
import MachineLearning.CantorCompactness
import MachineLearning.CantorSubshiftDimension

/-!
# The golden-mean subshift is homeomorphic to the whole Cantor truth space

Third cycle.  The previous cycles established that the Cantor truth space
`Cantor = ℕ → Bool` with the first-disagreement ultrametric is compact, complete and
totally separated, that the golden-mean subshift `GoldenMean` is a closed, perfect,
nowhere dense, uncountable subset, and that its `2⁻ⁿ`-covering number is exactly
`fib (n+2)`, giving box dimension `log φ / log 2 < 1`.

The bold conjecture of this cycle is that the *strictly smaller box dimension is invisible
to topology*: the subshift is homeomorphic to the entire space.  We prove this by an explicit
construction rather than by invoking any abstract characterisation of the Cantor set.

The homeomorphism is the **golden substitution** `0 ↦ 0`, `1 ↦ 10` applied letterwise to an
infinite stream.  Writing `blockPos x n` for the position at which the `n`-th block starts,
the coded stream `code x` is `true` exactly at the starting positions of blocks coming from a
`true` input letter.  Because a `true` letter is always immediately followed by an inserted
`false`, the image lies in the subshift; because every golden-mean stream decomposes uniquely
into the blocks `0` and `10`, the map is onto the subshift; and because the first `n` output
letters depend only on the first `n` input letters, it is distance non-increasing, hence
continuous.  Compactness upgrades the continuous bijection to a homeomorphism.

## Main results

* `code_mem_goldenMean` — the substitution lands in the subshift.
* `code_injective`, `code_surjOn_goldenMean` — it is a bijection onto the subshift.
* `dist_code_le`, `continuous_code` — it is `1`-Lipschitz.
* `goldenMeanHomeomorph : Cantor ≃ₜ GoldenMean` — the homeomorphism.
-/

namespace FractalTruthCompactness

open FractalTruthMetric Metric Filter
open scoped Topology

/-! ## Block positions of the golden substitution -/

/-- Position at which the `n`-th block of the substitution `0 ↦ 0`, `1 ↦ 10` starts. -/
def blockPos (x : Cantor) : ℕ → ℕ
  | 0 => 0
  | (n + 1) => blockPos x n + (if x n = true then 2 else 1)

@[simp] theorem blockPos_zero (x : Cantor) : blockPos x 0 = 0 := rfl

theorem blockPos_succ (x : Cantor) (n : ℕ) :
    blockPos x (n + 1) = blockPos x n + (if x n = true then 2 else 1) := rfl

theorem blockPos_lt_succ (x : Cantor) (n : ℕ) : blockPos x n < blockPos x (n + 1) := by
  rw [blockPos_succ]
  split <;> omega

theorem strictMono_blockPos (x : Cantor) : StrictMono (blockPos x) :=
  strictMono_nat_of_lt_succ (blockPos_lt_succ x)

theorem le_blockPos (x : Cantor) (n : ℕ) : n ≤ blockPos x n :=
  (strictMono_blockPos x).le_apply

theorem blockPos_injective (x : Cantor) : Function.Injective (blockPos x) :=
  (strictMono_blockPos x).injective

/-- No position strictly between the start of a `true` block and the start of the next one. -/
theorem blockPos_ne_succ_of_true {x : Cantor} {n m : ℕ} (hx : x n = true) :
    blockPos x m ≠ blockPos x n + 1 := by
  have hnext : blockPos x (n + 1) = blockPos x n + 2 := by
    rw [blockPos_succ, if_pos hx]
  rcases le_or_gt m n with h | h
  · have hle := (strictMono_blockPos x).monotone h
    omega
  · have hle := (strictMono_blockPos x).monotone (show n + 1 ≤ m by omega)
    omega

/-! ## The coding map -/

open Classical in
/-- The golden substitution applied to an infinite stream: the output is `true` exactly at the
starting position of a block coming from a `true` input letter. -/
noncomputable def code (x : Cantor) : Cantor :=
  fun j => if ∃ n, blockPos x n = j ∧ x n = true then true else false

theorem code_eq_true_iff (x : Cantor) (j : ℕ) :
    code x j = true ↔ ∃ n, blockPos x n = j ∧ x n = true := by
  classical
  unfold code
  split <;> simp_all

theorem code_blockPos (x : Cantor) (n : ℕ) : code x (blockPos x n) = x n := by
  rw [Bool.eq_iff_iff, code_eq_true_iff]
  constructor
  · rintro ⟨m, hm, hmt⟩
    rwa [blockPos_injective x hm] at hmt
  · intro h
    exact ⟨n, rfl, h⟩

/-- **The substitution lands in the golden-mean subshift.** -/
theorem code_mem_goldenMean (x : Cantor) : code x ∈ GoldenMean := by
  intro j hj
  obtain ⟨h1, h2⟩ := hj
  obtain ⟨n, hn, hxn⟩ := (code_eq_true_iff x j).mp h1
  obtain ⟨m, hm, -⟩ := (code_eq_true_iff x (j + 1)).mp h2
  exact blockPos_ne_succ_of_true (n := n) (m := m) hxn (by omega)

/-! ## Injectivity -/

/-- Block positions only depend on the letters read so far. -/
theorem blockPos_congr {x y : Cantor} {n : ℕ} (h : AgreeTo n x y) :
    ∀ k, k ≤ n → blockPos x k = blockPos y k := by
  intro k
  induction k with
  | zero => intro _; rfl
  | succ m ih =>
      intro hm
      have hmn : m < n := by omega
      rw [blockPos_succ, blockPos_succ, ih (by omega), h m hmn]

theorem code_injective : Function.Injective code := by
  intro x y hxy
  by_contra hne
  set n := firstDiff x y with hn
  have hA : AgreeTo n x y := agreeTo_firstDiff x y
  have hpos : blockPos x n = blockPos y n := blockPos_congr hA n le_rfl
  have hdiff : x n ≠ y n := firstDiff_spec hne
  have h1 : code x (blockPos x n) = x n := code_blockPos x n
  have h2 : code y (blockPos y n) = y n := code_blockPos y n
  rw [hxy, hpos] at h1
  exact hdiff (h1.symm.trans h2)

/-! ## Surjectivity onto the subshift -/

/-- Positions of the block decomposition of a golden-mean stream. -/
def decodePos (z : Cantor) : ℕ → ℕ
  | 0 => 0
  | (n + 1) => decodePos z n + (if z (decodePos z n) = true then 2 else 1)

/-- The stream of block letters read off a golden-mean stream. -/
def decode (z : Cantor) : Cantor := fun n => z (decodePos z n)

theorem blockPos_decode (z : Cantor) : ∀ n, blockPos (decode z) n = decodePos z n
  | 0 => rfl
  | (n + 1) => by
      rw [blockPos_succ, blockPos_decode z n]
      rfl

/-- Every position is either the start of a block or the second letter of a `10` block. -/
theorem decodePos_covers (z : Cantor) : ∀ j : ℕ,
    (∃ n, decodePos z n = j) ∨ (∃ n, decodePos z n + 1 = j ∧ z (decodePos z n) = true) := by
  intro j
  induction j with
  | zero => exact Or.inl ⟨0, rfl⟩
  | succ i ih =>
      rcases ih with ⟨n, hn⟩ | ⟨n, hn, hz⟩
      · by_cases hzn : z (decodePos z n) = true
        · exact Or.inr ⟨n, by omega, hzn⟩
        · refine Or.inl ⟨n + 1, ?_⟩
          rw [decodePos, if_neg hzn]
          omega
      · refine Or.inl ⟨n + 1, ?_⟩
        rw [decodePos, if_pos hz]
        omega

/-- **The substitution recovers every golden-mean stream.** -/
theorem code_decode {z : Cantor} (hz : z ∈ GoldenMean) : code (decode z) = z := by
  funext j
  rcases decodePos_covers z j with ⟨n, hn⟩ | ⟨n, hn, hzt⟩
  · have h := code_blockPos (decode z) n
    rw [blockPos_decode, hn] at h
    rw [h]
    show z (decodePos z n) = z j
    rw [hn]
  · have hfalse : code (decode z) j = false := by
      rw [← Bool.not_eq_true]
      intro h
      obtain ⟨m, hm, -⟩ := (code_eq_true_iff (decode z) j).mp h
      rw [blockPos_decode] at hm
      have hbad : blockPos (decode z) m ≠ blockPos (decode z) n + 1 :=
        blockPos_ne_succ_of_true (n := n) (m := m) (by rw [decode]; exact hzt)
      rw [blockPos_decode, blockPos_decode] at hbad
      exact hbad (by omega)
    have hzj : z j = false := by
      rw [← Bool.not_eq_true]
      intro h
      exact hz (decodePos z n) ⟨hzt, by rw [hn]; exact h⟩
    rw [hfalse, hzj]

theorem code_surjOn_goldenMean : Set.SurjOn code Set.univ GoldenMean := by
  intro z hz
  exact ⟨decode z, Set.mem_univ _, code_decode hz⟩

/-- The image of the coding map is exactly the golden-mean subshift. -/
theorem range_code : Set.range code = GoldenMean := by
  ext z
  constructor
  · rintro ⟨x, rfl⟩
    exact code_mem_goldenMean x
  · intro hz
    exact ⟨decode z, code_decode hz⟩

/-! ## Continuity -/

theorem agreeTo_code {x y : Cantor} {n : ℕ} (h : AgreeTo n x y) :
    AgreeTo n (code x) (code y) := by
  intro j hj
  have key : ∀ (u v : Cantor), AgreeTo n u v → code u j = true → code v j = true := by
    intro u v huv hu
    obtain ⟨k, hk, hkt⟩ := (code_eq_true_iff u j).mp hu
    have hkn : k < n := by
      by_contra hcon
      push_neg at hcon
      have h1 : blockPos u n ≤ blockPos u k := (strictMono_blockPos u).monotone hcon
      have h2 : n ≤ blockPos u n := le_blockPos u n
      omega
    refine (code_eq_true_iff v j).mpr ⟨k, ?_, ?_⟩
    · rw [← blockPos_congr huv k (le_of_lt hkn)]; exact hk
    · rw [← huv k hkn]; exact hkt
  rw [Bool.eq_iff_iff]
  exact ⟨key x y h, key y x (agreeTo_symm h)⟩

/-- The coding map is distance non-increasing. -/
theorem dist_code_le (x y : Cantor) : dist (code x) (code y) ≤ dist x y := by
  by_cases hxy : x = y
  · subst hxy; simp
  · have hd : dist x y = (2 : ℝ) ^ (-(firstDiff x y : ℤ)) := by
      rw [dist_eq, cantorDist, if_neg hxy]
    rw [hd]
    exact (dist_le_iff_agreeTo _ _ _).mpr (agreeTo_code (agreeTo_firstDiff x y))

theorem continuous_code : Continuous code :=
  (LipschitzWith.of_dist_le_mul (K := 1) (by simpa using dist_code_le)).continuous

/-! ## The homeomorphism -/

/-- The coding map viewed as a map into the subshift. -/
noncomputable def codeToSubshift (x : Cantor) : GoldenMean := ⟨code x, code_mem_goldenMean x⟩

theorem codeToSubshift_bijective : Function.Bijective codeToSubshift := by
  constructor
  · intro x y h
    exact code_injective (congrArg Subtype.val h)
  · rintro ⟨z, hz⟩
    exact ⟨decode z, Subtype.ext (code_decode hz)⟩

theorem continuous_codeToSubshift : Continuous codeToSubshift :=
  continuous_code.subtype_mk _

/-- **The golden-mean subshift is homeomorphic to the whole Cantor truth space.**  Although
its box dimension `log φ / log 2` is strictly smaller than the dimension `1` of the ambient
space, the two spaces are topologically indistinguishable: the explicit golden substitution
`0 ↦ 0`, `1 ↦ 10` is a homeomorphism. -/
noncomputable def goldenMeanHomeomorph : Cantor ≃ₜ GoldenMean :=
  Continuous.homeoOfEquivCompactToT2
    (f := Equiv.ofBijective codeToSubshift codeToSubshift_bijective) continuous_codeToSubshift

@[simp] theorem goldenMeanHomeomorph_apply (x : Cantor) :
    (goldenMeanHomeomorph x : Cantor) = code x := rfl

/-- Proposition-level form of the main theorem of this cycle: the golden-mean subshift and the
full Cantor truth space are homeomorphic, even though their box dimensions differ. -/
theorem nonempty_homeomorph_goldenMean : Nonempty (Cantor ≃ₜ GoldenMean) :=
  ⟨goldenMeanHomeomorph⟩

end FractalTruthCompactness