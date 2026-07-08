import Mathlib

/-!
# Antipodality via the opposite-semicube Helly property

We model the vertices of the hypercube `Q_n` as functions `Fin n → Fin 2` (a *bit-vector*).
For a finite vertex set `S : Finset (Fin n → Fin 2)`, a coordinate `i` and a bit `b`, the
*semicube* `semicube S i b` is the set of vertices of `S` whose `i`-th coordinate equals `b`.
The *opposite* semicubes at coordinate `i` are `semicube S i 0` and `semicube S i 1`.

The *antipode* of a vertex `v` is its bit complement `anti v`, and `S` is *antipodal* if it is
closed under taking antipodes.

We prove a characterization of antipodality:

* `antipodal_opposite_semicube_iso` (forward) — if `S` is antipodal, then for every coordinate `i`
  the antipode map is an *isometric isomorphism* `semicube S i 0 ≅ semicube S i 1`.  This is proved
  directly from the definition of the antipode.

* `semicube_helly` — a standalone combinatorial Helly-number-2 statement for the semicubes of the
  full hypercube: a pairwise-consistent family of coordinate constraints is globally satisfiable.

* `opposite_semicube_iso_helly_implies_antipodal` (converse) — if every pair of opposite semicubes
  of `S` is isometrically isomorphic *and* the semicubes of `S` satisfy the Helly property, then `S`
  is antipodal.  The antipode of a vertex `v` is constructed as the unique common vertex of the
  family of "flipped" semicubes; the Helly property upgrades the pairwise-satisfiability (which
  follows from mere cardinality balance of opposite semicubes) to global satisfiability.  This proof
  never refers to antipodality, avoiding circularity.

* `antipodal_iff_opposite_semicube_swap` — combining the two directions: under the Helly hypothesis,
  `S` is antipodal iff its opposite semicubes are isometrically isomorphic.

All results hold for every dimension `n`.
-/

open Finset

namespace AntipodalSemicube

variable {n : ℕ}

/-- Vertices of the hypercube `Q_n`. -/
abbrev V (n : ℕ) := Fin n → Fin 2

/-- Bit complement on `Fin 2`. -/
def opp (b : Fin 2) : Fin 2 := if b = 0 then 1 else 0

@[simp] lemma opp_zero : opp 0 = 1 := rfl
@[simp] lemma opp_one : opp 1 = 0 := rfl

@[simp] lemma opp_opp (b : Fin 2) : opp (opp b) = b := by fin_cases b <;> rfl

lemma opp_ne (b : Fin 2) : opp b ≠ b := by fin_cases b <;> decide

lemma opp_injective : Function.Injective opp := by
  intro a b h; fin_cases a <;> fin_cases b <;> simp_all

lemma opp_eq_iff {a b : Fin 2} : opp a = b ↔ a = opp b := by
  fin_cases a <;> fin_cases b <;> decide

/-- Hamming distance between two vertices: the number of coordinates in which they differ. -/
def hdist (u v : V n) : ℕ := (univ.filter (fun i => u i ≠ v i)).card

/-- The antipode (bit complement) of a vertex. -/
def anti (v : V n) : V n := fun i => opp (v i)

@[simp] lemma anti_anti (v : V n) : anti (anti v) = v := by
  funext i; simp [anti]

lemma anti_injective : Function.Injective (anti (n := n)) := by
  intro u v h
  funext i
  have := congrFun h i
  simpa [anti] using opp_injective this

@[simp] lemma anti_apply (v : V n) (i : Fin n) : anti v i = opp (v i) := rfl

/-- The antipode map preserves Hamming distance. -/
lemma hdist_anti (u v : V n) : hdist (anti u) (anti v) = hdist u v := by
  unfold hdist
  congr 1
  ext i
  simp only [mem_filter, mem_univ, true_and, anti_apply]
  exact ⟨fun h h' => h (by rw [h']), fun h h' => h (opp_injective h')⟩

/-- The semicube `S_i^b = {v ∈ S | v i = b}`. -/
def semicube (S : Finset (V n)) (i : Fin n) (b : Fin 2) : Finset (V n) :=
  S.filter (fun v => v i = b)

@[simp] lemma mem_semicube {S : Finset (V n)} {i : Fin n} {b : Fin 2} {v : V n} :
    v ∈ semicube S i b ↔ v ∈ S ∧ v i = b := by
  simp [semicube]

/-- An *isometric isomorphism* between two finite vertex sets: a bijection between them that
preserves Hamming distance. -/
def IsometricIso (A B : Finset (V n)) : Prop :=
  ∃ f : V n → V n, Set.BijOn f ↑A ↑B ∧ ∀ x ∈ A, ∀ y ∈ A, hdist (f x) (f y) = hdist x y

/-- `S` is *antipodal* if it is closed under taking antipodes. -/
def Antipodal (S : Finset (V n)) : Prop := ∀ v ∈ S, anti v ∈ S

/-- The *Helly property* for the semicubes of `S`: a family of coordinate constraints whose members
are (individually nonempty and) pairwise jointly satisfiable inside `S` is globally satisfiable
inside `S`.  (Helly number 2: pairwise intersection implies total intersection.) -/
def SemicubeHelly (S : Finset (V n)) : Prop :=
  ∀ F : Finset (Fin n × Fin 2),
    (∀ p ∈ F, ∃ x ∈ S, x p.1 = p.2) →
    (∀ p ∈ F, ∀ q ∈ F, ∃ x ∈ S, x p.1 = p.2 ∧ x q.1 = q.2) →
    ∃ x ∈ S, ∀ p ∈ F, x p.1 = p.2

/-!
## Result 1: forward direction
-/

/-
**Forward direction.** If `S` is antipodal, then for every coordinate `i` the antipode map
restricts to an isometric isomorphism between the opposite semicubes `semicube S i 0` and
`semicube S i 1`.
-/
theorem antipodal_opposite_semicube_iso (S : Finset (V n)) (hS : Antipodal S) (i : Fin n) :
    IsometricIso (semicube S i 0) (semicube S i 1) := by
  refine' ⟨ fun v => fun j => if v j = 0 then 1 else 0, _, _ ⟩;
  · refine' ⟨ _, _, _ ⟩;
    · intro v hv; simp_all +decide [ semicube ] ;
      convert hS v hv.1 using 1;
    · intro v hv w hw; simp_all +decide [ funext_iff ] ;
      grind;
    · intro v hv; use fun j => if v j = 0 then 1 else 0; simp_all +decide ;
      exact ⟨ hS v hv.1, funext fun j => by cases Fin.exists_fin_two.mp ⟨ v j, rfl ⟩ <;> aesop ⟩;
  · intro x hx y hy; simp +decide [ hdist ] ;
    exact congr_arg _ ( by ext i; cases Fin.exists_fin_two.mp ⟨ x i, rfl ⟩ <;> cases Fin.exists_fin_two.mp ⟨ y i, rfl ⟩ <;> aesop )

/-!
## Result 2: Helly property for the full hypercube
-/

/-
**Helly property for semicubes of the full hypercube.** A family `F` of coordinate constraints
`(i, b)` such that every two of them are jointly satisfiable by some vertex is satisfiable by a
single vertex.  (In the full cube two constraints are jointly satisfiable iff they do not fix the
same coordinate to different bits, so pairwise consistency is exactly coordinate consistency.)
-/
theorem semicube_helly (F : Finset (Fin n × Fin 2))
    (hpair : ∀ p ∈ F, ∀ q ∈ F, ∃ v : V n, v p.1 = p.2 ∧ v q.1 = q.2) :
    ∃ v : V n, ∀ p ∈ F, v p.1 = p.2 := by
  by_contra! h_contra;
  choose f hf using h_contra;
  -- Define a function g that maps each coordinate i to the bit b such that (i, b) is in F.
  obtain ⟨g, hg⟩ : ∃ g : Fin n → Fin 2, ∀ p ∈ F, p.2 = g p.1 := by
    use fun i => if h : ∃ b, (i, b) ∈ F then Classical.choose h else 0;
    intro p hp; have := Classical.choose_spec ( show ∃ b, ( p.1, b ) ∈ F from ⟨ p.2, hp ⟩ ) ; simp_all +decide ;
    grind +suggestions;
  exact hf g |>.2 ( hg _ ( hf g |>.1 ) ▸ rfl )

/-!
## Auxiliary cardinality facts
-/

/-
An isometric isomorphism between two finite sets equates their cardinalities.
-/
lemma IsometricIso.card_eq {A B : Finset (V n)} (h : IsometricIso A B) : A.card = B.card := by
  obtain ⟨ f, hf ⟩ := h;
  rw [ ← Finset.card_image_of_injOn hf.1.injOn ];
  rw [ show image f A = B by exact Finset.coe_injective <| by simpa using hf.1.image_eq ]

/-- Cardinality balance of opposite semicubes obtained from the isomorphism hypothesis. -/
lemma balance_of_iso {S : Finset (V n)}
    (hiso : ∀ i, IsometricIso (semicube S i 0) (semicube S i 1)) (i : Fin n) :
    (semicube S i 0).card = (semicube S i 1).card :=
  (hiso i).card_eq

/-
**Pairwise flip from cardinality balance.**  If, for every coordinate, the two opposite
semicubes of `S` have equal cardinality, then for every `v ∈ S` and every pair of coordinates `i, j`
there is a vertex `w ∈ S` that flips `v` in both coordinates.  (For fixed `i, j`, balancing these
two coordinates forces the four "quadrant" counts to satisfy `n₀₀ = n₁₁` and `n₀₁ = n₁₀`; since the
quadrant of `v` is nonempty, so is the diagonally opposite one.)
-/
lemma flip_two_of_balance (S : Finset (V n))
    (hbal : ∀ i, (semicube S i 0).card = (semicube S i 1).card)
    {v : V n} (hv : v ∈ S) (i j : Fin n) :
    ∃ w ∈ S, w i = opp (v i) ∧ w j = opp (v j) := by
  by_cases hij : i = j;
  · cases Fin.exists_fin_two.mp ⟨ v i, rfl ⟩ <;> simp_all +decide [ semicube ];
    · exact Exists.elim ( Finset.card_pos.mp ( by rw [ ← hbal j ] ; exact Finset.card_pos.mpr ⟨ v, by aesop ⟩ ) ) fun x hx => ⟨ x, by aesop ⟩;
    · exact Exists.elim ( Finset.card_pos.mp ( by erw [ hbal j ] ; exact Finset.card_pos.mpr ⟨ v, by aesop ⟩ ) ) fun x hx => ⟨ x, by aesop ⟩;
  · -- By definition of $N$, we know that $N(opp(v_i), opp(v_j)) = N(v_i, v_j)$.
    have hN : (Finset.filter (fun x => x i = opp (v i) ∧ x j = opp (v j)) S).card = (Finset.filter (fun x => x i = v i ∧ x j = v j) S).card := by
      have hN : ∀ c d : Fin 2, (Finset.filter (fun x => x i = c ∧ x j = d) S).card + (Finset.filter (fun x => x i = c ∧ x j = opp d) S).card = (Finset.filter (fun x => x i = c) S).card := by
        intro c d; rw [ ← Finset.card_union_of_disjoint ] ; congr; ext x; by_cases hi : x j = d <;> by_cases hj : x j = opp d <;> simp_all +decide [ Finset.filter_and ] ;
        · grind +suggestions;
        · simp +contextual [ Finset.disjoint_left ];
          exact fun _ _ _ _ => by fin_cases d <;> trivial;
      have hN' : ∀ c d : Fin 2, (Finset.filter (fun x => x i = c ∧ x j = d) S).card + (Finset.filter (fun x => x i = opp c ∧ x j = d) S).card = (Finset.filter (fun x => x j = d) S).card := by
        intros c d; rw [ ← Finset.card_union_of_disjoint ] ; congr; ext x; by_cases hx : x i = c <;> by_cases hx' : x j = d <;> simp +decide [ hx, hx' ] ;
        · grind;
        · grind +locals;
        · simp +contextual [ Finset.disjoint_left, opp ];
          grind;
      have := hN ( v i ) ( v j ) ; have := hN ( opp ( v i ) ) ( v j ) ; have := hN' ( v i ) ( v j ) ; have := hN' ( v i ) ( opp ( v j ) ) ; simp_all +decide [ semicube ] ;
      cases Fin.exists_fin_two.mp ⟨ v i, rfl ⟩ <;> cases Fin.exists_fin_two.mp ⟨ v j, rfl ⟩ <;> simp_all +decide only [opp];
      · grind +suggestions;
      · grind;
      · grind;
      · grind;
    exact Exists.elim ( Finset.card_pos.mp ( by rw [ hN ] ; exact Finset.card_pos.mpr ⟨ v, by aesop ⟩ ) ) fun x hx => ⟨ x, by aesop ⟩

/-!
## Result 3: converse direction (no circularity)
-/

/-
**Converse direction.** If every pair of opposite semicubes of `S` is isometrically isomorphic
and the semicubes of `S` satisfy the Helly property, then `S` is antipodal.

The proof constructs, for each `v ∈ S`, the family of "flipped" constraints
`{(i, opp (v i)) | i}`.  Cardinality balance (from the isomorphisms) makes this family pairwise
satisfiable inside `S` (`flip_two_of_balance`), and the Helly hypothesis upgrades this to a single
common vertex `x ∈ S` with `x i = opp (v i)` for all `i`, i.e. `x = anti v`.  Antipodality is never
invoked.
-/
theorem opposite_semicube_iso_helly_implies_antipodal (S : Finset (V n))
    (hiso : ∀ i, IsometricIso (semicube S i 0) (semicube S i 1))
    (hHelly : SemicubeHelly S) :
    Antipodal S := by
  intro v hv;
  have := hHelly ( Finset.univ.image ( fun i : Fin n => ( i, opp ( v i ) ) ) ) ?_ ?_ <;> simp_all +decide [ Finset.mem_image ] ;
  · obtain ⟨ x, hx₁, hx₂ ⟩ := this; convert hx₁; ext i; aesop;
  · intro i; have := flip_two_of_balance S ( balance_of_iso hiso ) hv i i; aesop;
  · exact fun i j => flip_two_of_balance S ( balance_of_iso hiso ) hv i j

/-!
## Result 4: the biconditional
-/

/-- **Antipodality characterization.**  Under the Helly property for the semicubes of `S`, the set
`S` is antipodal if and only if all of its opposite semicubes are isometrically isomorphic. -/
theorem antipodal_iff_opposite_semicube_swap (S : Finset (V n)) (hHelly : SemicubeHelly S) :
    Antipodal S ↔ ∀ i, IsometricIso (semicube S i 0) (semicube S i 1) := by
  constructor
  · intro hS i
    exact antipodal_opposite_semicube_iso S hS i
  · intro hiso
    exact opposite_semicube_iso_helly_implies_antipodal S hiso hHelly

end AntipodalSemicube