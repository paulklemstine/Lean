/-
# Tropical Span Contraction: the algebraic endpoint of the decoding trade-off

This file develops the *algebraic* half of a cost / failure-probability trade-off for
min-plus (tropical) decoders on a chain (a trellis).

## Setting

Fix a finite nonempty state space `S`. A *tropical transfer matrix* is a function
`A : S → S → ℝ`, acting on cost-to-go vectors by the min-plus rule

  `(A ⊗ v) a = min_b (A a b + v b)`.

A matrix is **tropically stochastic** (`Stochastic`) when every row has minimum `0`;
this is the min-plus analogue of a row-stochastic matrix and is obtained from an
arbitrary matrix by subtracting row minima, an operation that changes neither the
decoder's decisions nor the argmin structure.

The relevant "distance to a constant" is the **span seminorm**
`spanSemi v = max v - min v`, which is exactly the projective quantity a min-plus
decoder is sensitive to (adding a constant to `v` changes no decision).

## Main results

* `spanSemi_mulVec_le` — min-plus propagation is *nonexpansive* for the span seminorm
  (this needs tropical stochasticity).
* `spanSemi_mulVec_le_diam` — a **Dobrushin/Doeblin-type contraction bound**: one
  min-plus step compresses the span below the matrix *diameter* `diam A`,
  *independently of the input vector*. This holds with no hypothesis on `A` at all.
* `mulVec_mmul` — associativity of the min-plus action (the tropical semiring law).
* `spanSemi_windowApply_le_diam` — **absorption theorem**: after a window of `k`
  transfer steps, the span of the propagated vector is at most `diam (A (i+j))`
  for *any* single index `j < k` inside the window; i.e. it is bounded by the
  running minimum of the diameters over the window.
* `tropicalNoiseFloor` — **sharpness**: a two-state example in which the span is
  *exactly* `d` after every positive number of steps.  Hence min-plus memory loss is
  "one-step absorption to the diameter", **not** geometric decay: purely algebraic
  arguments can never produce a bound decaying in the window length `k`.

The last two results are the structural reason why the exponential-in-window-length
failure bound of `Tropical.DecodingTradeoff.Tradeoff` *must* come from probabilistic
independence rather than from tropical algebra.
-/

import Mathlib

open Finset

namespace Tropical.DecodingTradeoff

variable {S : Type*} [Fintype S] [Nonempty S]

/-! ## §1. Tropical minimum and maximum -/

/-- Tropical (min-plus) sum of a finite family: the minimum. -/
def tmin (f : S → ℝ) : ℝ := Finset.univ.inf' Finset.univ_nonempty f

/-- The maximum of a finite family, used to build the span seminorm. -/
def tmax (f : S → ℝ) : ℝ := Finset.univ.sup' Finset.univ_nonempty f

lemma tmin_le (f : S → ℝ) (s : S) : tmin f ≤ f s := Finset.inf'_le f (mem_univ s)

lemma le_tmax (f : S → ℝ) (s : S) : f s ≤ tmax f := Finset.le_sup' f (mem_univ s)

lemma le_tmin {c : ℝ} {f : S → ℝ} (h : ∀ s, c ≤ f s) : c ≤ tmin f :=
  Finset.le_inf' _ _ fun b _ => h b

lemma tmax_le {c : ℝ} {f : S → ℝ} (h : ∀ s, f s ≤ c) : tmax f ≤ c :=
  Finset.sup'_le _ _ fun b _ => h b

lemma exists_tmin (f : S → ℝ) : ∃ s, tmin f = f s := by
  obtain ⟨s, _, hs⟩ := Finset.exists_mem_eq_inf' (Finset.univ_nonempty (α := S)) f
  exact ⟨s, hs⟩

lemma exists_tmax (f : S → ℝ) : ∃ s, tmax f = f s := by
  obtain ⟨s, _, hs⟩ := Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := S)) f
  exact ⟨s, hs⟩

/-- The **span seminorm**: the projective size of a cost-to-go vector. -/
def spanSemi (v : S → ℝ) : ℝ := tmax v - tmin v

lemma spanSemi_nonneg (v : S → ℝ) : 0 ≤ spanSemi v := by
  have s := Classical.arbitrary S
  have h1 := tmin_le v s
  have h2 := le_tmax v s
  simp only [spanSemi]
  linarith

/-- The span seminorm is invariant under adding a constant: the decoder is projective. -/
lemma spanSemi_add_const (v : S → ℝ) (c : ℝ) : spanSemi (fun s => v s + c) = spanSemi v := by
  have h1 : tmax (fun s => v s + c) = tmax v + c := by
    refine le_antisymm (tmax_le fun s => by linarith [le_tmax v s]) ?_
    obtain ⟨s, hs⟩ := exists_tmax v
    have := le_tmax (fun s => v s + c) s
    rw [hs]; linarith
  have h2 : tmin (fun s => v s + c) = tmin v + c := by
    refine le_antisymm ?_ (le_tmin fun s => by linarith [tmin_le v s])
    obtain ⟨s, hs⟩ := exists_tmin v
    have := tmin_le (fun s => v s + c) s
    rw [hs]; linarith
  simp only [spanSemi, h1, h2]; ring

/-- If the span is small, all entries are within `spanSemi v` of each other. -/
lemma sub_le_spanSemi (v : S → ℝ) (a b : S) : v a - v b ≤ spanSemi v := by
  have h1 := le_tmax v a
  have h2 := tmin_le v b
  simp only [spanSemi]; linarith

/-! ## §2. Min-plus matrices -/

/-- Min-plus action of a transfer matrix on a cost-to-go vector. -/
def mulVec (A : S → S → ℝ) (v : S → ℝ) : S → ℝ := fun a => tmin (fun b => A a b + v b)

/-- Min-plus (tropical) matrix product. -/
def mmul (A B : S → S → ℝ) : S → S → ℝ := fun a c => tmin (fun b => A a b + B b c)

/-- A matrix is *tropically stochastic* when every row has tropical sum (= minimum) `0`. -/
def Stochastic (A : S → S → ℝ) : Prop := ∀ a, tmin (A a) = 0

/-- The **diameter** of a transfer matrix: the tropical Dobrushin coefficient. -/
def diam (A : S → S → ℝ) : ℝ := tmax fun a => tmax fun a' => tmax fun b => A a b - A a' b

lemma diam_bound (A : S → S → ℝ) (a a' b : S) : A a b - A a' b ≤ diam A := by
  refine le_trans (le_tmax (fun b => A a b - A a' b) b) ?_
  refine le_trans (le_tmax (fun a' => tmax fun b => A a b - A a' b) a') ?_
  exact le_tmax (fun a => tmax fun a' => tmax fun b => A a b - A a' b) a

lemma diam_nonneg (A : S → S → ℝ) : 0 ≤ diam A := by
  have a := Classical.arbitrary S
  have := diam_bound A a a a
  linarith

lemma nonneg_of_stochastic {A : S → S → ℝ} (h : Stochastic A) (a b : S) : 0 ≤ A a b := by
  have := tmin_le (A a) b; rw [h a] at this; exact this

lemma tmin_le_mulVec {A : S → S → ℝ} (h : Stochastic A) (v : S → ℝ) (a : S) :
    tmin v ≤ mulVec A v a :=
  le_tmin fun b => by linarith [nonneg_of_stochastic h a b, tmin_le v b]

lemma mulVec_le_tmax {A : S → S → ℝ} (h : Stochastic A) (v : S → ℝ) (a : S) :
    mulVec A v a ≤ tmax v := by
  obtain ⟨b, hb⟩ := exists_tmin (A a)
  have hab : A a b = 0 := by rw [← hb, h a]
  calc mulVec A v a ≤ A a b + v b := tmin_le _ b
    _ = v b := by rw [hab]; ring
    _ ≤ tmax v := le_tmax v b

/-- **Nonexpansiveness.** A tropically stochastic min-plus step never increases the span. -/
theorem spanSemi_mulVec_le {A : S → S → ℝ} (h : Stochastic A) (v : S → ℝ) :
    spanSemi (mulVec A v) ≤ spanSemi v := by
  have h1 : tmax (mulVec A v) ≤ tmax v := tmax_le fun a => mulVec_le_tmax h v a
  have h2 : tmin v ≤ tmin (mulVec A v) := le_tmin fun a => tmin_le_mulVec h v a
  simp only [spanSemi]; linarith

/-- **Tropical Dobrushin contraction.** One min-plus step compresses the span seminorm
below the diameter of the transfer matrix, *uniformly in the input vector*.
No stochasticity hypothesis is needed. -/
theorem spanSemi_mulVec_le_diam (A : S → S → ℝ) (v : S → ℝ) :
    spanSemi (mulVec A v) ≤ diam A := by
  obtain ⟨a, ha⟩ := exists_tmin (mulVec A v)
  have key : ∀ a', mulVec A v a' - mulVec A v a ≤ diam A := by
    intro a'
    obtain ⟨b, hb⟩ := exists_tmin (fun b => A a b + v b)
    have h1 : mulVec A v a' ≤ A a' b + v b := tmin_le _ b
    have h2 : mulVec A v a = A a b + v b := hb
    have := diam_bound A a' a b
    simp only [mulVec] at h1 h2 ⊢
    linarith
  have hmax : tmax (mulVec A v) ≤ diam A + mulVec A v a := tmax_le fun s => by linarith [key s]
  simp only [spanSemi, ha]
  linarith

/-- **Associativity** of the min-plus action: the tropical semiring law for transfer matrices. -/
theorem mulVec_mmul (A B : S → S → ℝ) (v : S → ℝ) :
    mulVec (mmul A B) v = mulVec A (mulVec B v) := by
  funext a
  apply le_antisymm
  · refine le_tmin fun b => ?_
    obtain ⟨c, hc⟩ := exists_tmin (fun c => B b c + v c)
    have h1 : mulVec (mmul A B) v a ≤ mmul A B a c + v c := tmin_le _ c
    have h2 : mmul A B a c ≤ A a b + B b c := tmin_le _ b
    simp only [mulVec] at h1 hc ⊢
    rw [hc]; linarith
  · refine le_tmin fun c => ?_
    obtain ⟨b, hb⟩ := exists_tmin (fun b => A a b + B b c)
    have h1 : mulVec A (mulVec B v) a ≤ A a b + mulVec B v b := tmin_le _ b
    have h2 : mulVec B v b ≤ B b c + v c := tmin_le _ c
    simp only [mmul] at hb ⊢
    rw [hb]; simp only [mulVec] at h1 h2 ⊢; linarith

/-! ## §2b. The monoid of tropically stochastic matrices

Tropically stochastic matrices are closed under the min-plus product, and the diameter is
*monotone* under composition on both sides: the tropical Dobrushin coefficient of a
product never exceeds the coefficient of either factor.  This is the matrix-level
counterpart of the absorption theorem of §3. -/

/-- Tropically stochastic matrices form a monoid under the min-plus product. -/
theorem Stochastic_mmul {A B : S → S → ℝ} (hA : Stochastic A) (hB : Stochastic B) :
    Stochastic (mmul A B) := by
  intro a
  refine le_antisymm ?_ (le_tmin fun c => le_tmin fun b => by
    linarith [nonneg_of_stochastic hA a b, nonneg_of_stochastic hB b c])
  obtain ⟨b₀, hb₀⟩ := exists_tmin (A a)
  obtain ⟨c₀, hc₀⟩ := exists_tmin (B b₀)
  have hA0 : A a b₀ = 0 := by rw [← hb₀, hA a]
  have hB0 : B b₀ c₀ = 0 := by rw [← hc₀, hB b₀]
  calc tmin (mmul A B a) ≤ mmul A B a c₀ := tmin_le _ c₀
    _ ≤ A a b₀ + B b₀ c₀ := tmin_le _ b₀
    _ = 0 := by rw [hA0, hB0]; ring

/-- The column of a min-plus product is the min-plus image of the corresponding column. -/
lemma mmul_column (A B : S → S → ℝ) (c : S) :
    (fun a => mmul A B a c) = mulVec A (fun b => B b c) := rfl

/-- The diameter of a matrix is the largest span of its columns. -/
lemma spanSemi_column_le_diam (B : S → S → ℝ) (c : S) :
    spanSemi (fun a => B a c) ≤ diam B := by
  obtain ⟨a, ha⟩ := exists_tmax (fun a => B a c)
  obtain ⟨a', ha'⟩ := exists_tmin (fun a => B a c)
  simp only [spanSemi, ha, ha']
  exact diam_bound B a a' c

/-- Every column of a min-plus product has span at most the diameter of the *left* factor. -/
theorem diam_mmul_le_left (A B : S → S → ℝ) : diam (mmul A B) ≤ diam A := by
  refine tmax_le fun a => tmax_le fun a' => tmax_le fun c => ?_
  have h1 : mmul A B a c - mmul A B a' c ≤ spanSemi (fun a => mmul A B a c) :=
    sub_le_spanSemi (fun a => mmul A B a c) a a'
  have h2 : spanSemi (fun a => mmul A B a c) ≤ diam A := by
    rw [mmul_column]; exact spanSemi_mulVec_le_diam A _
  linarith

/-- ... and, for a stochastic left factor, at most the diameter of the *right* factor. -/
theorem diam_mmul_le_right {A B : S → S → ℝ} (hA : Stochastic A) : diam (mmul A B) ≤ diam B := by
  refine tmax_le fun a => tmax_le fun a' => tmax_le fun c => ?_
  have h1 : mmul A B a c - mmul A B a' c ≤ spanSemi (fun a => mmul A B a c) :=
    sub_le_spanSemi (fun a => mmul A B a c) a a'
  have h2 : spanSemi (fun a => mmul A B a c) ≤ diam B := by
    rw [mmul_column]
    exact le_trans (spanSemi_mulVec_le hA _) (spanSemi_column_le_diam B c)
  linarith

/-- **Monotonicity of the tropical Dobrushin coefficient under composition.** -/
theorem diam_mmul_le_min {A B : S → S → ℝ} (hA : Stochastic A) :
    diam (mmul A B) ≤ min (diam A) (diam B) :=
  le_min (diam_mmul_le_left A B) (diam_mmul_le_right hA)

/-! ## §2c. Sup-norm nonexpansiveness -/

lemma mulVec_mono (A : S → S → ℝ) {v w : S → ℝ} (h : ∀ s, v s ≤ w s) (a : S) :
    mulVec A v a ≤ mulVec A w a :=
  le_tmin fun b => le_trans (tmin_le (fun b => A a b + v b) b) (by linarith [h b])

lemma mulVec_add_const (A : S → S → ℝ) (v : S → ℝ) (c : ℝ) (a : S) :
    mulVec A (fun s => v s + c) a = mulVec A v a + c := by
  refine le_antisymm ?_ ?_
  · obtain ⟨b, hb⟩ := exists_tmin (fun b => A a b + v b)
    have h1 : mulVec A (fun s => v s + c) a ≤ A a b + (v b + c) := tmin_le _ b
    simp only [mulVec] at h1 hb ⊢
    rw [hb]; linarith
  · obtain ⟨b, hb⟩ := exists_tmin (fun b => A a b + (v b + c))
    have h1 : mulVec A v a ≤ A a b + v b := tmin_le _ b
    simp only [mulVec] at h1 hb ⊢
    rw [hb]; linarith

/-- **Min-plus propagation is `1`-Lipschitz for the sup norm.**  Together with
`spanSemi_mulVec_le` this says a tropical decoder is stable both absolutely and
projectively. -/
theorem mulVec_lipschitz (A : S → S → ℝ) (v w : S → ℝ) (a : S) :
    |mulVec A v a - mulVec A w a| ≤ tmax (fun s => |v s - w s|) := by
  set M := tmax (fun s => |v s - w s|) with hM
  have hvw : ∀ s, v s ≤ w s + M := fun s => by
    have := le_tmax (fun s => |v s - w s|) s
    have h2 : v s - w s ≤ |v s - w s| := le_abs_self _
    rw [← hM] at this; linarith
  have hwv : ∀ s, w s ≤ v s + M := fun s => by
    have := le_tmax (fun s => |v s - w s|) s
    have h2 : w s - v s ≤ |v s - w s| := by
      rw [abs_sub_comm]; exact le_abs_self _
    rw [← hM] at this; linarith
  have h1 : mulVec A v a ≤ mulVec A w a + M := by
    have := mulVec_mono A hvw a
    rwa [mulVec_add_const] at this
  have h2 : mulVec A w a ≤ mulVec A v a + M := by
    have := mulVec_mono A hwv a
    rwa [mulVec_add_const] at this
  rw [abs_le]
  constructor <;> linarith

/-! ## §3. Windows -/

/-- `windowApply A i k v` propagates the terminal cost-to-go vector `v` backwards through
the `k` transfer matrices `A i, A (i+1), …, A (i+k-1)`.  This is the *horizon-`k`*
(windowed) decoder's cost-to-go vector at stage `i`. -/
def windowApply (A : ℕ → S → S → ℝ) : ℕ → ℕ → (S → ℝ) → (S → ℝ)
  | _, 0 => fun v => v
  | i, (k + 1) => fun v => mulVec (A i) (windowApply A (i + 1) k v)

@[simp] lemma windowApply_zero (A : ℕ → S → S → ℝ) (i : ℕ) (v : S → ℝ) :
    windowApply A i 0 v = v := rfl

lemma windowApply_succ (A : ℕ → S → S → ℝ) (i k : ℕ) (v : S → ℝ) :
    windowApply A i (k + 1) v = mulVec (A i) (windowApply A (i + 1) k v) := rfl

/-- Windows compose: propagating through `j + r` steps is propagating through the last
`r` and then the first `j`. -/
theorem windowApply_add (A : ℕ → S → S → ℝ) (j : ℕ) :
    ∀ (i r : ℕ) (v : S → ℝ),
      windowApply A i (j + r) v = windowApply A i j (windowApply A (i + j) r v) := by
  induction j with
  | zero => intro i r v; simp
  | succ j ih =>
      intro i r v
      have h : j + 1 + r = (j + r) + 1 := by omega
      have h2 : i + (j + 1) = (i + 1) + j := by omega
      rw [h, windowApply_succ, ih (i + 1) r v, windowApply_succ, h2]

/-- Nonexpansiveness propagates through a whole window. -/
theorem spanSemi_windowApply_le {A : ℕ → S → S → ℝ} (hA : ∀ i, Stochastic (A i)) (k : ℕ) :
    ∀ (i : ℕ) (v : S → ℝ), spanSemi (windowApply A i k v) ≤ spanSemi v := by
  induction k with
  | zero => intro i v; simp
  | succ k ih =>
      intro i v
      rw [windowApply_succ]
      exact le_trans (spanSemi_mulVec_le (hA i) _) (ih (i + 1) v)

/-- **Absorption theorem.**  A single "informative" step (a transfer matrix of small
diameter) anywhere inside the window already bounds the span of the propagated vector.
Consequently the span after a length-`k` window is at most the *running minimum* of the
diameters over the window. -/
theorem spanSemi_windowApply_le_diam {A : ℕ → S → S → ℝ} (hA : ∀ i, Stochastic (A i))
    {i j k : ℕ} (hj : j < k) (v : S → ℝ) :
    spanSemi (windowApply A i k v) ≤ diam (A (i + j)) := by
  obtain ⟨m, hm⟩ : ∃ m, k = j + (m + 1) := ⟨k - j - 1, by omega⟩
  subst hm
  rw [windowApply_add A j i (m + 1) v, windowApply_succ]
  refine le_trans (spanSemi_windowApply_le hA j i _) ?_
  exact spanSemi_mulVec_le_diam _ _

/-! ## §4. Sharpness: the tropical noise floor

The absorption theorem cannot be improved to a bound that decays with the window
length `k`.  We exhibit a two-state chain whose span is *exactly* the diameter `d`
after every positive number of steps. -/

section NoiseFloor

/-- The symmetric two-state transfer matrix with off-diagonal cost `d`. -/
def twoState (d : ℝ) : Fin 2 → Fin 2 → ℝ := fun a b => if a = b then 0 else d

lemma tmin_fin2 (f : Fin 2 → ℝ) : tmin f = min (f 0) (f 1) := by
  refine le_antisymm (le_min (tmin_le f 0) (tmin_le f 1)) (le_tmin fun s => ?_)
  fin_cases s
  · exact min_le_left _ _
  · exact min_le_right _ _

lemma tmax_fin2 (f : Fin 2 → ℝ) : tmax f = max (f 0) (f 1) := by
  refine le_antisymm (tmax_le fun s => ?_) (max_le (le_tmax f 0) (le_tmax f 1))
  fin_cases s
  · exact le_max_left _ _
  · exact le_max_right _ _

lemma twoState_stochastic {d : ℝ} (hd : 0 ≤ d) : Stochastic (twoState d) := by
  intro a
  fin_cases a <;> simp [tmin_fin2, twoState, hd]

lemma twoState_diam {d : ℝ} (hd : 0 ≤ d) : diam (twoState d) = d := by
  simp [diam, tmax_fin2, twoState, hd]

/-- The vector `![0, d]` is a fixed point of the two-state min-plus propagation. -/
lemma twoState_fixed {d : ℝ} (hd : 0 ≤ d) : mulVec (twoState d) ![0, d] = ![0, d] := by
  funext a
  have h0 : mulVec (twoState d) ![(0:ℝ), d] 0 = min 0 (d + d) := by
    simp [mulVec, tmin_fin2, twoState]
  have h1 : mulVec (twoState d) ![(0:ℝ), d] 1 = min (d + 0) (0 + d) := by
    simp [mulVec, tmin_fin2, twoState]
  fin_cases a
  · rw [show ((⟨0, by norm_num⟩ : Fin 2)) = (0 : Fin 2) from rfl, h0,
      min_eq_left (by linarith)]
    simp
  · rw [show ((⟨1, by norm_num⟩ : Fin 2)) = (1 : Fin 2) from rfl, h1]
    simp

/-- The fixed point survives arbitrarily long windows. -/
lemma twoState_iterate {d : ℝ} (hd : 0 ≤ d) (k : ℕ) :
    ∀ i : ℕ, windowApply (fun _ => twoState d) i k ![0, d] = ![0, d] := by
  induction k with
  | zero => intro i; simp
  | succ k ih => intro i; rw [windowApply_succ, ih (i + 1), twoState_fixed hd]

/-- **Tropical noise floor.**  For the two-state chain of diameter `d`, the span of the
propagated cost-to-go vector equals `d` after *every* number of steps: it never decays.
Combined with `twoState_diam`, the absorption bound `spanSemi_windowApply_le_diam` is
therefore attained with equality for all window lengths, so no purely algebraic bound of
the form `spanSemi ≤ ρ ^ k * spanSemi v` with `ρ < 1` can hold.  The exponential gain of a
long decoding window must come from probabilistic fluctuation of the diameters, not from
tropical algebra. -/
theorem tropicalNoiseFloor {d : ℝ} (hd : 0 ≤ d) (k i : ℕ) :
    spanSemi (windowApply (fun _ => twoState d) i k ![0, d]) = diam (twoState d) := by
  rw [twoState_iterate hd k i, twoState_diam hd]
  simp [spanSemi, tmax_fin2, tmin_fin2, max_eq_right hd, min_eq_left hd]

end NoiseFloor

end Tropical.DecodingTradeoff