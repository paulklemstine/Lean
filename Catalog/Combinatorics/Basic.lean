/-
# Divisors, the graph Laplacian, and chip-firing: basic theory

This file sets up the divisor theory of a finite graph (the combinatorial model of a
tropical curve / metric graph), following Baker–Norine.

Main definitions:
* `TropicalRR.Divisor V` : an element of `ℤ^V`;
* `TropicalRR.degD` : the degree of a divisor;
* `TropicalRR.lap G f` : the graph Laplacian applied to `f : V → ℤ`;
* `TropicalRR.LinEquiv G` : linear equivalence of divisors (`D' = D - lap f`);
* `TropicalRR.Effective`, `TropicalRR.Winnable` : effectivity and winnability of a divisor.

Main results:
* `TropicalRR.degD_lap` : the Laplacian image has degree `0`;
* `TropicalRR.LinEquiv.degD_eq` : linear equivalence preserves degree;
* `TropicalRR.const_of_lap_eq_zero` : on a connected graph the kernel of the
  Laplacian consists exactly of the constants;
* `TropicalRR.lap_indicator` : the set-firing formula.
-/
import Mathlib

namespace TropicalRR

open Finset

variable {V : Type*} [Fintype V]

/-- A divisor on a graph with vertex set `V` is an integer-valued function on vertices. -/
abbrev Divisor (V : Type*) := V → ℤ

variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The degree of a divisor. -/
def degD (D : Divisor V) : ℤ := ∑ v, D v

/-- The graph Laplacian applied to an integer function.  Subtracting `lap G f` from a
divisor is the result of firing `f v` chips from each vertex `v`. -/
def lap (f : V → ℤ) : Divisor V := fun v => ∑ w ∈ G.neighborFinset v, (f v - f w)

@[simp] lemma degD_add (D E : Divisor V) : degD (D + E) = degD D + degD E := by
  simp [degD, Finset.sum_add_distrib]

@[simp] lemma degD_sub (D E : Divisor V) : degD (D - E) = degD D - degD E := by
  simp [degD, Finset.sum_sub_distrib]

@[simp] lemma degD_neg (D : Divisor V) : degD (-D) = -degD D := by
  simp [degD]

@[simp] lemma lap_zero : lap G 0 = 0 := by
  funext v; simp [lap]

lemma lap_add (f g : V → ℤ) : lap G (f + g) = lap G f + lap G g := by
  funext v
  simp only [lap, Pi.add_apply, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl (by intros; ring)

lemma lap_neg (f : V → ℤ) : lap G (-f) = -lap G f := by
  funext v
  simp only [lap, Pi.neg_apply, ← Finset.sum_neg_distrib]
  exact Finset.sum_congr rfl (by intros; ring)

lemma lap_apply (f : V → ℤ) (v : V) :
    lap G f v = (G.degree v : ℤ) * f v - ∑ w ∈ G.neighborFinset v, f w := by
  rw [lap, Finset.sum_sub_distrib, Finset.sum_const,
    SimpleGraph.card_neighborFinset_eq_degree, nsmul_eq_mul]

/-- Summing a function of ordered adjacent pairs is symmetric in the two coordinates. -/
lemma sum_adj_comm (F : V → V → ℤ) :
    ∑ v, ∑ w ∈ G.neighborFinset v, F v w = ∑ v, ∑ w ∈ G.neighborFinset v, F w v := by
  rw [Finset.sum_comm' (t' := (univ : Finset V)) (s' := fun y => G.neighborFinset y)
    (f := fun x y => F y x)]
  · intro x y
    simp [SimpleGraph.mem_neighborFinset, SimpleGraph.adj_comm]

/-- The Laplacian image always has degree zero: firing chips preserves the total number. -/
@[simp] lemma degD_lap (f : V → ℤ) : degD (lap G f) = 0 := by
  have h := sum_adj_comm G (fun v w => f v - f w)
  have h2 : ∑ v, ∑ w ∈ G.neighborFinset v, (f w - f v)
      = -∑ v, ∑ w ∈ G.neighborFinset v, (f v - f w) := by
    rw [← Finset.sum_neg_distrib]
    exact Finset.sum_congr rfl fun v _ => by
      rw [← Finset.sum_neg_distrib]; exact Finset.sum_congr rfl (by intros; ring)
  simp only [degD, lap]
  linarith [h, h2]

/-! ### Linear equivalence -/

/-- Two divisors are linearly equivalent when they differ by an element of the image of
the Laplacian, i.e. one is obtained from the other by a chip-firing move. -/
def LinEquiv (D D' : Divisor V) : Prop := ∃ f : V → ℤ, D' = D - lap G f

lemma LinEquiv.refl (D : Divisor V) : LinEquiv G D D := ⟨0, by simp⟩

lemma LinEquiv.symm {D D' : Divisor V} (h : LinEquiv G D D') : LinEquiv G D' D := by
  obtain ⟨f, hf⟩ := h
  exact ⟨-f, by rw [lap_neg, hf]; abel⟩

lemma LinEquiv.trans {D E F : Divisor V} (h₁ : LinEquiv G D E) (h₂ : LinEquiv G E F) :
    LinEquiv G D F := by
  obtain ⟨f, hf⟩ := h₁
  obtain ⟨g, hg⟩ := h₂
  refine ⟨f + g, ?_⟩
  rw [lap_add, hg, hf]; abel

lemma LinEquiv.degD_eq {D D' : Divisor V} (h : LinEquiv G D D') : degD D' = degD D := by
  obtain ⟨f, hf⟩ := h
  rw [hf, degD_sub, degD_lap, sub_zero]

/-- Linear equivalence is compatible with translation by a fixed divisor. -/
lemma LinEquiv.add_right {D D' : Divisor V} (h : LinEquiv G D D') (E : Divisor V) :
    LinEquiv G (D + E) (D' + E) := by
  obtain ⟨f, hf⟩ := h
  exact ⟨f, by rw [hf]; abel⟩

lemma LinEquiv.sub_left {D D' : Divisor V} (h : LinEquiv G D D') (E : Divisor V) :
    LinEquiv G (E - D) (E - D') := by
  obtain ⟨f, hf⟩ := h
  exact ⟨-f, by rw [lap_neg, hf]; abel⟩

/-! ### Effectivity -/

/-- A divisor is effective when it is everywhere nonnegative. -/
def Effective (D : Divisor V) : Prop := ∀ v, 0 ≤ D v

lemma Effective.degD_nonneg {D : Divisor V} (h : Effective D) : 0 ≤ degD D :=
  Finset.sum_nonneg fun v _ => h v

omit [Fintype V] in
lemma Effective.add {D E : Divisor V} (hD : Effective D) (hE : Effective E) :
    Effective (D + E) := fun v => add_nonneg (hD v) (hE v)

/-- A divisor is *winnable* if it is linearly equivalent to an effective divisor;
this is the set `W` in the Baker–Norine dichotomy. -/
def Winnable (D : Divisor V) : Prop := ∃ D', LinEquiv G D D' ∧ Effective D'

lemma Winnable.of_effective {D : Divisor V} (h : Effective D) : Winnable G D :=
  ⟨D, LinEquiv.refl G D, h⟩

lemma Winnable.of_linEquiv {D D' : Divisor V} (h : LinEquiv G D D') (hw : Winnable G D') :
    Winnable G D := by
  obtain ⟨E, hE, hEe⟩ := hw
  exact ⟨E, h.trans G hE, hEe⟩

lemma Winnable.degD_nonneg {D : Divisor V} (h : Winnable G D) : 0 ≤ degD D := by
  obtain ⟨E, hE, hEe⟩ := h
  rw [← hE.degD_eq G]
  exact hEe.degD_nonneg

/-- If `D` and `E` are both winnable, so is `D + E`. -/
lemma Winnable.add {D E : Divisor V} (hD : Winnable G D) (hE : Winnable G E) :
    Winnable G (D + E) := by
  obtain ⟨A, ⟨f, hf⟩, hA⟩ := hD
  obtain ⟨B, ⟨g, hg⟩, hB⟩ := hE
  refine ⟨A + B, ⟨f + g, ?_⟩, hA.add hB⟩
  rw [lap_add, hf, hg]; abel

/-- Winnability is monotone: adding an effective divisor keeps a divisor winnable. -/
lemma Winnable.add_effective {D E : Divisor V} (hD : Winnable G D) (hE : Effective E) :
    Winnable G (D + E) := hD.add G (Winnable.of_effective G hE)

/-! ### The kernel of the Laplacian -/

/-- If `f` is Laplacian-harmonic then it is constant along edges out of any vertex where it
attains its maximum. -/
lemma lap_eq_zero_step {f : V → ℤ} (h : lap G f = 0) {v : V} (hv : ∀ u, f u ≤ f v)
    {w : V} (hw : G.Adj v w) : f w = f v := by
  have hz : ∑ u ∈ G.neighborFinset v, (f v - f u) = 0 := by
    have := congrFun h v; simpa [lap] using this
  have hnn : ∀ u ∈ G.neighborFinset v, 0 ≤ f v - f u := by
    intro u _; linarith [hv u]
  have := (Finset.sum_eq_zero_iff_of_nonneg hnn).1 hz w (by
    simpa [SimpleGraph.mem_neighborFinset] using hw)
  omega

/-- On a connected graph, the kernel of the Laplacian consists of the constant functions. -/
lemma const_of_lap_eq_zero (hc : G.Connected) {f : V → ℤ} (h : lap G f = 0) (u v : V) :
    f u = f v := by
  obtain ⟨v₀, -, hv₀⟩ :=
    Finset.exists_max_image (univ : Finset V) f ⟨u, Finset.mem_univ u⟩
  have hmax : ∀ x, f x ≤ f v₀ := fun x => hv₀ x (Finset.mem_univ x)
  have key : ∀ {a b : V}, G.Walk a b → f a = f v₀ → f b = f v₀ := by
    intro a b p
    induction p with
    | nil => exact fun h => h
    | @cons a c b hadj q ih =>
        intro hfa
        refine ih ?_
        have : f c = f a := lap_eq_zero_step G h (v := a) (fun x => by rw [hfa]; exact hmax x) hadj
        rw [this, hfa]
  have hall : ∀ x : V, f x = f v₀ := by
    intro x
    obtain ⟨p⟩ := hc.preconnected v₀ x
    exact key p rfl
  rw [hall u, hall v]

variable [DecidableEq V]

/-! ### Firing a set of vertices -/

/-- The indicator function of a finset, as an integer function. -/
def indic (S : Finset V) : V → ℤ := fun v => if v ∈ S then 1 else 0

/-- The number of edges from `v` leaving the set `S`. -/
def outdeg (S : Finset V) (v : V) : ℕ := ((G.neighborFinset v) \ S).card

/-- The number of edges from `v` into the set `S`. -/
def indeg (S : Finset V) (v : V) : ℕ := ((G.neighborFinset v) ∩ S).card

lemma lap_indicator (S : Finset V) (v : V) :
    lap G (indic S) v = if v ∈ S then (outdeg G S v : ℤ) else -(indeg G S v : ℤ) := by
  by_cases hv : v ∈ S
  · simp only [hv, if_true, lap, indic, outdeg]
    rw [Finset.sdiff_eq_filter, ← Finset.sum_boole]
    exact Finset.sum_congr rfl fun w _ => by by_cases hw : w ∈ S <;> simp [hw]
  · simp only [hv, if_false, lap, indic, indeg]
    rw [← Finset.filter_mem_eq_inter, ← Finset.sum_boole, ← Finset.sum_neg_distrib]
    exact Finset.sum_congr rfl fun w _ => by by_cases hw : w ∈ S <;> simp [hw]

lemma outdeg_eq_sum (A : Finset V) (v : V) :
    (outdeg G A v : ℤ) = ∑ w ∈ G.neighborFinset v, (if w ∈ A then 0 else 1) := by
  rw [outdeg, Finset.sdiff_eq_filter, ← Finset.sum_boole]
  exact Finset.sum_congr rfl fun w _ => by by_cases hw : w ∈ A <;> simp [hw]

lemma indeg_eq_sum (A : Finset V) (v : V) :
    (indeg G A v : ℤ) = ∑ w ∈ G.neighborFinset v, (if w ∈ A then 1 else 0) := by
  rw [indeg, ← Finset.filter_mem_eq_inter, ← Finset.sum_boole]

/-! ### The set where a function attains its maximum -/

/-- The set of vertices at which `f` attains its maximum. -/
def maxSet (f : V → ℤ) : Finset V := Finset.univ.filter (fun v => ∀ w, f w ≤ f v)

omit [DecidableEq V] in
lemma mem_maxSet {f : V → ℤ} {v : V} : v ∈ maxSet f ↔ ∀ w, f w ≤ f v := by
  simp [maxSet]

omit [DecidableEq V] in
lemma maxSet_nonempty [Nonempty V] (f : V → ℤ) : (maxSet f).Nonempty := by
  obtain ⟨v, -, hv⟩ :=
    Finset.exists_max_image (Finset.univ : Finset V) f Finset.univ_nonempty
  exact ⟨v, mem_maxSet.2 fun w => hv w (Finset.mem_univ w)⟩

omit [DecidableEq V] in
lemma lt_of_not_mem_maxSet {f : V → ℤ} {v w : V} (hv : v ∈ maxSet f) (hw : w ∉ maxSet f) :
    f w < f v := by
  rw [mem_maxSet] at hv
  rw [maxSet, Finset.mem_filter] at hw
  push_neg at hw
  obtain ⟨u, hu⟩ := hw (Finset.mem_univ w)
  exact lt_of_lt_of_le hu (hv u)

/-- Firing according to `f` removes at least `outdeg A v` chips from every vertex `v` of the
maximum set `A` of `f`. -/
lemma outdeg_le_lap_maxSet {f : V → ℤ} {v : V} (hv : v ∈ maxSet f) :
    (outdeg G (maxSet f) v : ℤ) ≤ lap G f v := by
  rw [outdeg_eq_sum, lap]
  refine Finset.sum_le_sum fun w _ => ?_
  by_cases hwA : w ∈ maxSet f
  · simp only [hwA, if_true]
    have := (mem_maxSet.1 hv) w
    linarith
  · simp only [hwA, if_false]
    have := lt_of_not_mem_maxSet hv hwA
    linarith

omit [DecidableEq V] in
lemma lap_sub (f g : V → ℤ) : lap G (f - g) = lap G f - lap G g := by
  funext v
  simp only [lap, Pi.sub_apply, ← Finset.sum_sub_distrib]
  exact Finset.sum_congr rfl fun w _ => by ring

omit [DecidableEq V] in
lemma lap_const (c : ℤ) : lap G (fun _ => c) = 0 := by
  funext v; simp [lap]

omit [DecidableEq V] in
lemma lap_sub_const (f : V → ℤ) (c : ℤ) : lap G (fun v => f v - c) = lap G f := by
  funext v
  simp only [lap]
  exact Finset.sum_congr rfl fun w _ => by ring

omit [DecidableEq V] in
lemma lap_smul (n : ℤ) (f : V → ℤ) : lap G (fun v => n * f v) = fun v => n * lap G f v := by
  funext v
  simp only [lap, Finset.mul_sum]
  exact Finset.sum_congr rfl fun w _ => by ring

/-! ### Genus and the canonical divisor -/

/-- The genus (first Betti number) of a connected graph: `|E| - |V| + 1`. -/
def genus : ℤ := (G.edgeFinset.card : ℤ) - (Fintype.card V : ℤ) + 1

/-- The canonical divisor `K = ∑ (deg v - 2) v`. -/
def canonical : Divisor V := fun v => (G.degree v : ℤ) - 2

omit [DecidableEq V] in
/-- `deg K = 2g - 2`. -/
theorem degD_canonical : degD (canonical G) = 2 * genus G - 2 := by
  have h : ∑ v, G.degree v = 2 * G.edgeFinset.card := SimpleGraph.sum_degrees_eq_twice_card_edges G
  have h' : ((∑ v, G.degree v : ℕ) : ℤ) = 2 * (G.edgeFinset.card : ℤ) := by exact_mod_cast h
  rw [Nat.cast_sum] at h'
  simp only [degD, canonical, genus, Finset.sum_sub_distrib, Finset.sum_const,
    Finset.card_univ, nsmul_eq_mul, h']
  ring

end TropicalRR