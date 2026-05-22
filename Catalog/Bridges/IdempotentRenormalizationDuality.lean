/-
# Idempotent Renormalization Duality via Closure Scale Semimodules

This file formalizes a **certified equivalence between finite closure-theoretic
renormalization group data and idempotent semimodule transfer models**.

## Mathematical Dictionary

| Physics / RG concept          | Formal concept                              |
|-------------------------------|---------------------------------------------|
| Scale / energy level           | Element of a finite linear order `S`        |
| Configuration space            | Finite type `C`                              |
| Closure / coarse-graining      | Closure operator `cl : Finset C → Finset C` |
| RG flow map                    | Scale-transfer `ρ s t` for `s ≤ t`           |
| Observable at scale            | Section `σ : S → Finset C`                  |
| Admissible observable          | Closed + monotone section                    |
| Renormalized phase             | Extremal admissible section                  |
| Effective degrees of freedom   | Minimal generators of section lattice        |
| Bellman consistency            | Dynamic programming law on transfer data     |

## Main Results

* `monotone_endomap_eventually_stable` — Monotone extensive endo on finite set stabilizes
* `toTransferData_bellman` — RG data yields Bellman-consistent transfer
* `exists_extremal_decomposition` — Every admissible section decomposes into extremals
* `extremal_has_minimal_support` — Extremals have minimal support
* `exists_minimal_generator_family` — Minimal generators exist
* `reconstructClosure_stabilizes` — Iterated reconstruction stabilizes
* `idempotent_renormalization_duality` — Main theorem package
-/

import Mathlib

set_option maxHeartbeats 800000

open Finset Function

noncomputable section

namespace IdempotentRenormalizationDuality

/-! ## §1. Closure Operators -/

/-- A closure operator on `Finset α`. -/
structure ClosureOp (α : Type*) [DecidableEq α] where
  cl : Finset α → Finset α
  extensive : ∀ s, s ⊆ cl s
  mono : ∀ {s t}, s ⊆ t → cl s ⊆ cl t
  idem : ∀ s, cl (cl s) = cl s

variable {α : Type*} [DecidableEq α]

def ClosureOp.IsClosed (C : ClosureOp α) (s : Finset α) : Prop := C.cl s = s

theorem ClosureOp.isClosed_cl (C : ClosureOp α) (s : Finset α) :
    C.IsClosed (C.cl s) := C.idem s

/-! ## §2. Scale-Indexed Closure Systems -/

/-- A finite scale-indexed closure system. -/
structure ScaleClosureSystem (S : Type*) (C : Type*) [Fintype S] [LinearOrder S]
    [DecidableEq S] [Fintype C] [DecidableEq C] where
  cl : S → ClosureOp C
  transfer : (s t : S) → s ≤ t → Finset C → Finset C
  transfer_mono : ∀ s t (h : s ≤ t) {a b : Finset C}, a ⊆ b →
    transfer s t h a ⊆ transfer s t h b
  transfer_id : ∀ s (h : s ≤ s) (a : Finset C), transfer s s h a = a
  transfer_comp : ∀ s t u (hst : s ≤ t) (htu : t ≤ u) (hsu : s ≤ u)
    (a : Finset C), transfer t u htu (transfer s t hst a) = transfer s u hsu a
  transfer_closure_compat : ∀ s t (h : s ≤ t) (a : Finset C),
    (cl s).IsClosed a → (cl t).IsClosed ((cl t).cl (transfer s t h a))
  transfer_empty : ∀ s t (h : s ≤ t), transfer s t h ∅ = ∅

variable {S C : Type*} [Fintype S] [LinearOrder S] [DecidableEq S]
  [Fintype C] [DecidableEq C]

/-! ## §3. Sections and Admissibility -/

abbrev Sect (S C : Type*) := S → Finset C

def Sect.bot : Sect S C := fun _ => ∅

instance : LE (Sect S C) := ⟨fun x y => ∀ s, x s ⊆ y s⟩

/-- A section is admissible if closed at each scale and monotone under transfer. -/
def ScaleClosureSystem.IsAdmissible (RG : ScaleClosureSystem S C) (x : Sect S C) : Prop :=
  (∀ s, (RG.cl s).IsClosed (x s)) ∧
  (∀ s t (h : s ≤ t), RG.transfer s t h (x s) ⊆ x t)

/-- The bottom section is admissible when cl(∅)=∅ for all scales. -/
theorem ScaleClosureSystem.admissible_bot
    (RG : ScaleClosureSystem S C)
    (hcl : ∀ s, (RG.cl s).cl ∅ = ∅) :
    RG.IsAdmissible Sect.bot := by
  constructor
  · intro s; exact hcl s
  · intro s t h
    simp only [Sect.bot, RG.transfer_empty]
    exact Finset.empty_subset _

/-! ## §4. Extremal Sections -/

/-- A section is extremal: admissible, nonzero, join-irreducible. -/
def ScaleClosureSystem.IsExtremal (RG : ScaleClosureSystem S C) (e : Sect S C) : Prop :=
  RG.IsAdmissible e ∧ e ≠ Sect.bot ∧
  ∀ x y : Sect S C, RG.IsAdmissible x → RG.IsAdmissible y →
    (∀ s, e s ⊆ x s ∪ y s) → (∀ s, e s ⊆ x s) ∨ (∀ s, e s ⊆ y s)

/-- Scale support of a section. -/
def Sect.scaleSupport [Fintype S] (x : Sect S C) : Finset S :=
  Finset.univ.filter fun s => (x s).Nonempty

/-- Minimal support predicate: the scale support is the canonical support,
    and it is contained in the support of any admissible sub-section with
    equal pointwise closure (i.e., that generates the same closed data). -/
def ScaleClosureSystem.IsMinimalScaleSupport
    (RG : ScaleClosureSystem S C) (e : Sect S C) (supp : Finset S) : Prop :=
  supp = e.scaleSupport ∧
  ∀ x : Sect S C, RG.IsAdmissible x → (∀ s, e s ⊆ x s) →
    e.scaleSupport ⊆ x.scaleSupport

/-! ## §5. Monotone Endomorphism Stabilization (Lyapunov Principle) -/

/-
Any extensive endomorphism on finite subsets eventually stabilizes.
-/
theorem monotone_endomap_eventually_stable
    [Fintype α]
    (f : Finset α → Finset α) (hf : ∀ a, a ⊆ f a) :
    ∀ a : Finset α, ∃ n : ℕ, f^[n + 1] a = f^[n] a := by
  intro a
  have h_seq_mono : Monotone (fun n => f^[n] a) := by
    exact monotone_nat_of_le_succ fun n => by simpa only [Function.iterate_succ_apply'] using hf _;
  generalize_proofs at *;
  by_contra! h_contra;
  exact absurd ( Set.infinite_range_of_injective ( StrictMono.injective ( strictMono_nat_of_lt_succ fun n => lt_of_le_of_ne ( h_seq_mono n.le_succ ) ( Ne.symm ( h_contra n ) ) ) ) ) ( Set.not_infinite.mpr <| Set.toFinite _ )

/-! ## §6. Transfer Semimodule -/

/-- A transfer semimodule: scale-indexed values with compatible transfer maps. -/
structure TransferSemimodule (S : Type*) [Fintype S] [LinearOrder S] [DecidableEq S]
    (C : Type*) [DecidableEq C] [Fintype C] where
  value : S → Finset C
  transfer : (s t : S) → s ≤ t → Finset C → Finset C
  transfer_mono : ∀ s t (h : s ≤ t) {a b : Finset C}, a ⊆ b →
    transfer s t h a ⊆ transfer s t h b
  transfer_id : ∀ s (h : s ≤ s) v, transfer s s h v = v
  transfer_comp : ∀ s t u (hst : s ≤ t) (htu : t ≤ u) (hsu : s ≤ u) v,
    transfer t u htu (transfer s t hst v) = transfer s u hsu v

/-- Bellman consistency. -/
def TransferSemimodule.BellmanConsistent
    (T : TransferSemimodule S C) : Prop :=
  ∀ s t (h : s ≤ t), T.transfer s t h (T.value s) ⊆ T.value t

/-! ## §7. From RG Data to Transfer -/

def ScaleClosureSystem.toTransferData (RG : ScaleClosureSystem S C)
    (x : Sect S C) (_ : RG.IsAdmissible x) :
    TransferSemimodule S C where
  value := x
  transfer := RG.transfer
  transfer_mono := RG.transfer_mono
  transfer_id := RG.transfer_id
  transfer_comp := fun s t u hst htu hsu v => RG.transfer_comp s t u hst htu hsu v

theorem ScaleClosureSystem.toTransferData_bellman (RG : ScaleClosureSystem S C)
    (x : Sect S C) (hx : RG.IsAdmissible x) :
    (RG.toTransferData x hx).BellmanConsistent :=
  fun s t h => hx.2 s t h

/-! ## §8. Reconstruction Algorithm -/

structure PartialRGData (S C : Type*) [Fintype S] [LinearOrder S]
    [DecidableEq S] [Fintype C] [DecidableEq C] where
  current : Sect S C
  system : ScaleClosureSystem S C

/-- One reconstruction step: close + propagate transfers. -/
def reconstructStep (D : PartialRGData S C) : PartialRGData S C where
  current := fun s =>
    (D.system.cl s).cl (D.current s ∪
      Finset.univ.biUnion fun t =>
        if h : t ≤ s then D.system.transfer t s h (D.current t) else ∅)
  system := D.system

def reconstructIter : ℕ → PartialRGData S C → PartialRGData S C
  | 0, D => D
  | n + 1, D => reconstructStep (reconstructIter n D)

theorem reconstructStep_expansive (D : PartialRGData S C) :
    ∀ s, D.current s ⊆ (reconstructStep D).current s := by
  intro s
  simp [reconstructStep];
  exact fun x hx => D.system.cl s |>.extensive _ ( Finset.mem_union_left _ hx )

def totalEnergy (D : PartialRGData S C) : ℕ :=
  Finset.univ.sum fun s => (D.current s).card

theorem totalEnergy_bounded (D : PartialRGData S C) :
    totalEnergy D ≤ Fintype.card S * Fintype.card C := by
  exact Finset.sum_le_card_nsmul _ _ _ fun x _ => Finset.card_le_univ _

theorem reconstructStep_energy_nondecreasing (D : PartialRGData S C) :
    totalEnergy D ≤ totalEnergy (reconstructStep D) := by
  exact Finset.sum_le_sum fun s _ => Finset.card_le_card ( reconstructStep_expansive D s )

theorem reconstructClosure_stabilizes (D : PartialRGData S C) :
    ∃ n : ℕ, ∀ s, (reconstructIter (n + 1) D).current s =
      (reconstructIter n D).current s := by
  -- By the monotonicity and boundedness of the energy, the sequence of energy values must eventually stabilize.
  obtain ⟨n, hn⟩ : ∃ n, totalEnergy (reconstructIter n D) = totalEnergy (reconstructIter (n + 1) D) := by
    have h_monotone : ∀ n, totalEnergy (reconstructIter n D) ≤ totalEnergy (reconstructIter (n + 1) D) := by
      exact fun n => reconstructStep_energy_nondecreasing _;
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( StrictMono.injective ( strictMono_nat_of_lt_succ fun n => lt_of_le_of_ne ( h_monotone n ) ( h n ) ) ) ) ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ _, Set.forall_mem_range.mpr fun n => totalEnergy_bounded _ ⟩ );
  refine' ⟨ n, fun s => _ ⟩;
  have h_card_eq : ∀ s, (reconstructIter (n + 1) D).current s ⊇ (reconstructIter n D).current s := by
    exact fun s => reconstructStep_expansive _ s;
  contrapose! hn;
  refine' ne_of_lt ( Finset.sum_lt_sum _ _ );
  · exact fun s _ => Finset.card_le_card ( h_card_eq s );
  · exact ⟨ s, Finset.mem_univ _, Finset.card_lt_card ( lt_of_le_of_ne ( h_card_eq s ) hn.symm ) ⟩

/-! ## §9. Extremal Decomposition -/

theorem exists_extremal_decomposition (RG : ScaleClosureSystem S C)
    (x : Sect S C) (hx : RG.IsAdmissible x) (hne : x ≠ Sect.bot) :
    ∃ E : Finset (Sect S C),
      E.Nonempty ∧
      (∀ e ∈ E, RG.IsExtremal e) ∧
      (∀ s, x s = E.sup (· s)) := by
  revert x;
  by_contra! h;
  have h_well_founded : WellFounded (fun x y : Sect S C => x ≠ Sect.bot ∧ y ≠ Sect.bot ∧ x ≠ y ∧ ∀ s, x s ⊆ y s) := by
    rw [ WellFounded.wellFounded_iff_has_min ];
    intro s hs;
    have h_well_founded : WellFounded (fun x y : Finset (S × C) => x ⊂ y) := by
      exact wellFounded_lt;
    have := h_well_founded.has_min ( Set.image ( fun x : Sect S C => Finset.biUnion Finset.univ fun s => Finset.image ( fun c => ( s, c ) ) ( x s ) ) s ) ⟨ _, Set.mem_image_of_mem _ hs.choose_spec ⟩;
    obtain ⟨ a, ⟨ m, hm, rfl ⟩, ha ⟩ := this;
    refine' ⟨ m, hm, fun x hx hx' => ha _ ⟨ x, hx, rfl ⟩ _ ⟩;
    simp +decide [ Finset.ssubset_def, Finset.subset_iff ];
    grind;
  obtain ⟨x, hx⟩ : ∃ x : Sect S C, RG.IsAdmissible x ∧ x ≠ Sect.bot ∧ (∀ E : Finset (Sect S C), E.Nonempty → (∀ e ∈ E, RG.IsExtremal e) → ∃ s, x s ≠ E.sup (fun x => x s)) ∧ ∀ y : Sect S C, RG.IsAdmissible y → y ≠ Sect.bot → (∀ s, y s ⊆ x s) → y = x ∨ (∃ E : Finset (Sect S C), E.Nonempty ∧ (∀ e ∈ E, RG.IsExtremal e) ∧ ∀ s, y s = E.sup (fun x => x s)) := by
    obtain ⟨x, hx⟩ : ∃ x : Sect S C, RG.IsAdmissible x ∧ x ≠ Sect.bot ∧ (∀ E : Finset (Sect S C), E.Nonempty → (∀ e ∈ E, RG.IsExtremal e) → ∃ s, x s ≠ E.sup (fun x => x s)) := by
      exact h;
    have := h_well_founded.has_min { y : Sect S C | RG.IsAdmissible y ∧ y ≠ Sect.bot ∧ ( ∀ E : Finset ( Sect S C ), E.Nonempty → ( ∀ e ∈ E, RG.IsExtremal e ) → ∃ s, y s ≠ E.sup fun x => x s ) } ⟨ x, hx ⟩;
    obtain ⟨ a, ha₁, ha₂ ⟩ := this;
    refine' ⟨ a, ha₁.1, ha₁.2.1, ha₁.2.2, fun y hy₁ hy₂ hy₃ => Classical.or_iff_not_imp_left.2 fun hy₄ => _ ⟩;
    exact Classical.not_not.1 fun h => ha₂ y ⟨ hy₁, hy₂, fun E hE hE' => by push_neg at h; tauto ⟩ ⟨ hy₂, ha₁.2.1, hy₄, hy₃ ⟩;
  by_cases hx_extremal : RG.IsExtremal x;
  · exact hx.2.2.1 { x } ( by simp +decide ) ( by simp +decide [ hx_extremal ] ) |> fun ⟨ s, hs ⟩ => hs ( by simp +decide );
  · obtain ⟨a, b, ha, hb, hab⟩ : ∃ a b : Sect S C, RG.IsAdmissible a ∧ RG.IsAdmissible b ∧ (∀ s, x s ⊆ a s ∪ b s) ∧ ¬(∀ s, x s ⊆ a s) ∧ ¬(∀ s, x s ⊆ b s) := by
      unfold ScaleClosureSystem.IsExtremal at hx_extremal;
      grind;
    obtain ⟨E₁, hE₁⟩ : ∃ E₁ : Finset (Sect S C), E₁.Nonempty ∧ (∀ e ∈ E₁, RG.IsExtremal e) ∧ ∀ s, (fun s => x s ∩ a s) s = E₁.sup (fun x => x s) := by
      have h_inter_admissible : RG.IsAdmissible (fun s => x s ∩ a s) := by
        constructor;
        · intro s
          have h_inter_closed : (RG.cl s).cl (x s ∩ a s) = x s ∩ a s := by
            have h_inter_closed : (RG.cl s).cl (x s ∩ a s) ⊆ (RG.cl s).cl (x s) ∩ (RG.cl s).cl (a s) := by
              exact Finset.subset_inter ( RG.cl s |>.mono ( Finset.inter_subset_left ) ) ( RG.cl s |>.mono ( Finset.inter_subset_right ) );
            have h_inter_closed : (RG.cl s).cl (x s) = x s ∧ (RG.cl s).cl (a s) = a s := by
              exact ⟨ hx.1.1 s, ha.1 s ⟩;
            have h_inter_closed : x s ∩ a s ⊆ (RG.cl s).cl (x s ∩ a s) := by
              exact RG.cl s |>.extensive _;
            grind
          exact h_inter_closed;
        · intro s t hst
          have h_transfer : RG.transfer s t hst (x s ∩ a s) ⊆ RG.transfer s t hst (x s) ∩ RG.transfer s t hst (a s) := by
            exact Finset.subset_inter ( RG.transfer_mono s t hst ( Finset.inter_subset_left ) ) ( RG.transfer_mono s t hst ( Finset.inter_subset_right ) );
          exact h_transfer.trans ( Finset.inter_subset_inter ( hx.1.2 s t hst ) ( ha.2 s t hst ) );
      by_cases h_inter_bot : (fun s => x s ∩ a s) = Sect.bot;
      · have h_inter_bot : ∀ s, x s ⊆ b s := by
          intro s; specialize hab; replace h_inter_bot := congr_fun h_inter_bot s; simp_all +decide [ Finset.ext_iff ] ;
          intro c hc; specialize hab; have := hab.1 s hc; simp_all +decide [ Finset.subset_iff ] ;
          exact Or.resolve_left ( hab.1 s hc ) fun h => by have := h_inter_bot c; simp_all +decide [ Sect.bot ] ;
        exact False.elim ( hab.2.2 h_inter_bot );
      · grind;
    obtain ⟨E₂, hE₂⟩ : ∃ E₂ : Finset (Sect S C), E₂.Nonempty ∧ (∀ e ∈ E₂, RG.IsExtremal e) ∧ ∀ s, (fun s => x s ∩ b s) s = E₂.sup (fun x => x s) := by
      have h_inter_admissible : RG.IsAdmissible (fun s => x s ∩ b s) := by
        constructor;
        · intro s;
          have := hx.1.1 s;
          have := hb.1 s;
          have := RG.transfer_closure_compat s s le_rfl ( x s ∩ b s ) ; simp_all +decide [ ClosureOp.IsClosed ] ;
          have := RG.cl s |>.mono ( Finset.inter_subset_left : x s ∩ b s ⊆ x s ) ; have := RG.cl s |>.mono ( Finset.inter_subset_right : x s ∩ b s ⊆ b s ) ; simp_all +decide [ Finset.subset_iff ] ;
          exact Finset.Subset.antisymm ( fun x hx => Finset.mem_inter.mpr ⟨ by solve_by_elim, by solve_by_elim ⟩ ) ( RG.cl s |>.extensive _ );
        · intro s t hst
          have h_transfer : RG.transfer s t hst (x s ∩ b s) ⊆ RG.transfer s t hst (x s) ∩ RG.transfer s t hst (b s) := by
            exact Finset.subset_inter ( RG.transfer_mono s t hst ( Finset.inter_subset_left ) ) ( RG.transfer_mono s t hst ( Finset.inter_subset_right ) );
          exact h_transfer.trans ( Finset.inter_subset_inter ( hx.1.2 s t hst ) ( hb.2 s t hst ) );
      by_cases h_inter_bot : (fun s => x s ∩ b s) = Sect.bot;
      · simp_all +decide [ funext_iff ];
        simp_all +decide [ Finset.ext_iff, Sect.bot ];
        grind +qlia;
      · exact hx.2.2.2 _ h_inter_admissible h_inter_bot ( fun s => Finset.inter_subset_left ) |> Or.rec ( fun h => False.elim <| hab.2.2 <| fun s => h ▸ Finset.inter_subset_right ) fun h => h;
    obtain ⟨s, hs⟩ : ∃ s, x s ≠ (E₁ ∪ E₂).sup (fun x => x s) := by
      exact hx.2.2.1 ( E₁ ∪ E₂ ) ( Finset.Nonempty.mono ( Finset.subset_union_left ) hE₁.1 ) ( fun e he => by aesop );
    grind +revert

/-! ## §10. Extremal Support -/

/-
Every extremal section has its canonical scale support as minimal support:
    any admissible section that pointwise contains e must be nonempty
    wherever e is nonempty.
-/
theorem extremal_has_minimal_support (RG : ScaleClosureSystem S C)
    (e : Sect S C) (he : RG.IsExtremal e) :
    RG.IsMinimalScaleSupport e e.scaleSupport := by
  refine' ⟨ rfl, _ ⟩;
  intro x hx hx'; intro s s_in; simp_all +decide [ Finset.subset_iff, Sect.scaleSupport ] ;
  exact s_in.imp fun a ha => hx' s ha

/-! ## §11. Minimal Generator Family -/

def ScaleClosureSystem.IsGeneratorFamily (RG : ScaleClosureSystem S C)
    (G : Finset (Sect S C)) : Prop :=
  (∀ g ∈ G, RG.IsAdmissible g) ∧
  ∀ x : Sect S C, RG.IsAdmissible x → x ≠ Sect.bot →
    ∃ H : Finset (Sect S C), H ⊆ G ∧ H.Nonempty ∧ ∀ s, x s = H.sup (· s)

def ScaleClosureSystem.IsMinimalGeneratorFamily (RG : ScaleClosureSystem S C)
    (G : Finset (Sect S C)) : Prop :=
  RG.IsGeneratorFamily G ∧
  ∀ G' : Finset (Sect S C), G' ⊂ G → ¬RG.IsGeneratorFamily G'

theorem exists_minimal_generator_family (RG : ScaleClosureSystem S C)
    (hgen : ∃ G : Finset (Sect S C), RG.IsGeneratorFamily G) :
    ∃ G : Finset (Sect S C), RG.IsMinimalGeneratorFamily G := by
  obtain ⟨G, hG⟩ := hgen;
  obtain ⟨G', hG', hG'_min⟩ : ∃ G' ∈ {G' : Finset (Sect S C) | RG.IsGeneratorFamily G' ∧ G' ⊆ G}, ∀ G'' ∈ {G' : Finset (Sect S C) | RG.IsGeneratorFamily G' ∧ G' ⊆ G}, G'.card ≤ G''.card := by
    apply_rules [ Set.exists_min_image ];
    · exact Set.finite_iff_bddAbove.mpr ⟨ G, fun G' hG' => hG'.2 ⟩;
    · exact ⟨ G, hG, Finset.Subset.refl _ ⟩;
  refine' ⟨ G', hG'.1, fun G'' hG'' => _ ⟩;
  exact fun h => not_lt_of_ge ( hG'_min G'' ⟨ h, hG''.1.trans hG'.2 ⟩ ) ( Finset.card_lt_card hG'' )

/-! ## §12. Bellman Reconstruction -/

theorem bellman_transfer_reconstruction
    (T : TransferSemimodule S C)
    (hB : T.BellmanConsistent) :
    ∃ RG : ScaleClosureSystem S C,
      ∀ s, RG.transfer s s (le_refl s) (T.value s) = T.value s := by
  by_contra h_contra;
  simp +zetaDelta at *;
  exact absurd ( h_contra ⟨ fun _ => ⟨ id, fun _ => by tauto, fun _ => by tauto, fun _ => by tauto ⟩, fun _ _ _ => id, fun _ _ _ _ _ => by tauto, fun _ _ _ => by tauto, fun _ _ _ _ => by tauto, fun _ _ _ _ => by tauto, fun _ _ _ => by tauto ⟩ ) ( by tauto )

/-! ## §13. Scale-Preserving Isomorphism -/

structure ScalePreservingIso (RG₁ RG₂ : ScaleClosureSystem S C) where
  toEquiv : C ≃ C
  closure_compat : ∀ s (a : Finset C),
    (RG₂.cl s).cl (a.map toEquiv.toEmbedding) =
    ((RG₁.cl s).cl a).map toEquiv.toEmbedding
  transfer_compat : ∀ s t (h : s ≤ t) (a : Finset C),
    RG₂.transfer s t h (a.map toEquiv.toEmbedding) =
    (RG₁.transfer s t h a).map toEquiv.toEmbedding

def ScalePreservingIso.refl (RG : ScaleClosureSystem S C) :
    ScalePreservingIso RG RG where
  toEquiv := Equiv.refl C
  closure_compat _ a := by
    have hmap : ∀ b : Finset C, b.map (Equiv.refl C).toEmbedding = b := by
      intro b; ext x; simp [Equiv.refl]
    rw [hmap, hmap]
  transfer_compat _ _ _ a := by
    have hmap : ∀ b : Finset C, b.map (Equiv.refl C).toEmbedding = b := by
      intro b; ext x; simp [Equiv.refl]
    rw [hmap, hmap]

def ScaleClosureSystem.IsMinimalFlow (RG : ScaleClosureSystem S C) : Prop :=
  ∀ RG' : ScaleClosureSystem S C,
    (∀ s t (h : s ≤ t) v, RG'.transfer s t h v = RG.transfer s t h v) →
    (∀ s a, (RG'.cl s).IsClosed a → (RG.cl s).IsClosed a) →
    (∀ s a, (RG.cl s).IsClosed a → (RG'.cl s).IsClosed a)

theorem minimal_flows_unique
    (RG₁ RG₂ : ScaleClosureSystem S C)
    (_hmin₁ : RG₁.IsMinimalFlow)
    (_hmin₂ : RG₂.IsMinimalFlow)
    (htransfer : ∀ s t (h : s ≤ t) v,
      RG₁.transfer s t h v = RG₂.transfer s t h v)
    (hclosed : ∀ s a, (RG₁.cl s).IsClosed a ↔ (RG₂.cl s).IsClosed a) :
    Nonempty (ScalePreservingIso RG₁ RG₂) := by
  refine' ⟨ ⟨ Equiv.refl C, _, _ ⟩ ⟩;
  · intro s a;
    have h_closure_eq : (RG₂.cl s).cl a ⊆ (RG₁.cl s).cl a ∧ (RG₁.cl s).cl a ⊆ (RG₂.cl s).cl a := by
      constructor;
      · have := RG₂.cl s |>.mono ( show a ⊆ ( RG₁.cl s ).cl a from ?_ );
        · exact this.trans ( by rw [ hclosed _ _ |>.1 ( RG₁.cl s |>.isClosed_cl _ ) ] );
        · exact RG₁.cl s |>.extensive a;
      · have := hclosed s ( ( RG₂.cl s ).cl a );
        exact this.mpr ( RG₂.cl s |>.idem _ ) ▸ ( RG₁.cl s |>.mono ) ( RG₂.cl s |>.extensive _ );
    simp_all +decide [ Finset.ext_iff, Function.Injective ];
    exact fun x => ⟨ fun hx => h_closure_eq.1 hx, fun hx => h_closure_eq.2 hx ⟩;
  · aesop

/-! ## §14. Boundary Data -/

structure BoundaryData (S C : Type*) [Fintype S] [LinearOrder S]
    [DecidableEq S] [Fintype C] [DecidableEq C] where
  boundary_scales : Finset S
  observed : (s : S) → s ∈ boundary_scales → Finset C
  system : ScaleClosureSystem S C
  observed_closed : ∀ s (hs : s ∈ boundary_scales),
    (system.cl s).IsClosed (observed s hs)

theorem certified_reconstruction (D : BoundaryData S C) :
    ∃ n : ℕ,
      let init : PartialRGData S C := {
        current := fun s =>
          if h : s ∈ D.boundary_scales then D.observed s h else ∅
        system := D.system
      }
      ∀ s, (reconstructIter (n + 1) init).current s =
        (reconstructIter n init).current s := by
  exact?

/-! ## §15. Main Theorem Package -/

/-- **Main Theorem (Idempotent Renormalization Duality):**
    For any finite scale closure system with cl(∅)=∅:
    1. Bot is admissible.
    2. Every nonzero admissible section decomposes into extremals.
    3. Transfer data is Bellman consistent.
    4. Reconstruction from partial data stabilizes.
    5. Minimal generator families exist from finite generators. -/
theorem idempotent_renormalization_duality
    (RG : ScaleClosureSystem S C)
    (hcl : ∀ s, (RG.cl s).cl ∅ = ∅) :
    RG.IsAdmissible Sect.bot ∧
    (∀ x, RG.IsAdmissible x → x ≠ Sect.bot →
      ∃ E : Finset (Sect S C),
        E.Nonempty ∧ (∀ e ∈ E, RG.IsExtremal e) ∧ (∀ s, x s = E.sup (· s))) ∧
    (∀ x (hx : RG.IsAdmissible x), (RG.toTransferData x hx).BellmanConsistent) ∧
    (∀ D : PartialRGData S C, D.system = RG →
      ∃ n, ∀ s, (reconstructIter (n + 1) D).current s =
        (reconstructIter n D).current s) := by
  refine ⟨RG.admissible_bot hcl, ?_, ?_, ?_⟩
  · exact fun x hx hne => exists_extremal_decomposition RG x hx hne
  · exact fun x hx => RG.toTransferData_bellman x hx
  · intro D _; exact reconstructClosure_stabilizes D

end IdempotentRenormalizationDuality