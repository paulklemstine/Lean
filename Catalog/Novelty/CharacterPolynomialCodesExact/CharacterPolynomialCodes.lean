import Mathlib

/-!
# Character-polynomial codes: exact image size and nonredundant parameters

This file isolates the algebraic mechanism behind redundancy in a family of
character-polynomial codewords.  A parameter is first sent through a trace-like
additive map and then evaluated coordinatewise.  Equality of codewords is
therefore exactly equality modulo the kernel of that map.  The quotient by the
kernel gives a canonical nonredundant parameter space, and a transversal gives
an equivalent concrete parametrization.
-/

namespace CharacterPolynomialCode

section KernelQuotient

variable {A B W : Type*} [AddCommGroup A] [AddCommGroup B]

/-- A character-polynomial encoder: a trace-like additive map followed by an
injective evaluation/character map. -/
def encoder (trace : A →+ B) (evaluate : B → W) : A → W :=
  fun a => evaluate (trace a)

/-- The precise source of redundancy: two parameters produce the same word
exactly when their difference lies in the trace kernel. -/
theorem encoder_eq_iff_sub_mem_ker (trace : A →+ B) (evaluate : B → W)
    (hevaluate : Function.Injective evaluate) (a b : A) :
    encoder trace evaluate a = encoder trace evaluate b ↔ a - b ∈ trace.ker := by
  simp_all +decide [ encoder, hevaluate.eq_iff ];
  rw [ sub_eq_zero ]

/-- The encoder descends to the quotient by the trace kernel. -/
def quotientEncoder (trace : A →+ B) (evaluate : B → W) : A ⧸ trace.ker → W :=
  Quotient.lift (encoder trace evaluate) (by
    intro a b hab
    simp only [encoder]
    congr 1
    have hmem : -a + b ∈ trace.ker :=
      (QuotientAddGroup.leftRel_apply).mp hab
    exact neg_add_eq_zero.mp (show -trace a + trace b = 0 by simpa using hmem))

/-- Quotienting by the trace kernel removes all redundancy. -/
theorem quotientEncoder_injective (trace : A →+ B) (evaluate : B → W)
    (hevaluate : Function.Injective evaluate) :
    Function.Injective (quotientEncoder trace evaluate) := by
  -- Let $a, b \in A$. Assume $\overline{\text{encoder}}(a) = \overline{\text{encoder}}(b)$.
  intro a' b' h_eq
  obtain ⟨a, ha⟩ := QuotientAddGroup.mk_surjective a'
  obtain ⟨b, hb⟩ := QuotientAddGroup.mk_surjective b';
  have := encoder_eq_iff_sub_mem_ker trace evaluate hevaluate a b; simp_all +decide;
  simp_all +decide [ quotientEncoder, sub_eq_zero ];
  rw [ ← ha, ← hb, QuotientAddGroup.eq ] ; aesop;

/-- Every original codeword is represented by the quotient parametrization. -/
theorem range_quotientEncoder (trace : A →+ B) (evaluate : B → W) :
    Set.range (quotientEncoder trace evaluate) = Set.range (encoder trace evaluate) := by
  ext w
  simp [quotientEncoder, encoder];
  constructor <;> rintro ⟨ y, rfl ⟩;
  · obtain ⟨ x, rfl ⟩ := QuotientAddGroup.mk_surjective y; exact ⟨ x, rfl ⟩ ;
  · exact ⟨ QuotientAddGroup.mk y, rfl ⟩

end KernelQuotient

section Transversal

variable {A B W : Type*} [AddCommGroup A] [AddCommGroup B]

/-- A concrete transversal contains exactly one representative of each coset
of the trace kernel. -/
def IsKernelTransversal (trace : A →+ B) (T : Set A) : Prop :=
  ∀ q : A ⧸ trace.ker, ∃! a : A, a ∈ T ∧ (a : A ⧸ trace.ker) = q

/-- Restricting the encoder to any kernel transversal is injective. -/
theorem encoder_injective_on_transversal (trace : A →+ B) (evaluate : B → W)
    (hevaluate : Function.Injective evaluate) (T : Set A)
    (hT : IsKernelTransversal trace T) :
    Set.InjOn (encoder trace evaluate) T := by
  intro a ha b hb hab;
  obtain ⟨q, hq⟩ : ∃ q : A ⧸ trace.ker, a ∈ T ∧ (a : A ⧸ trace.ker) = q ∧ b ∈ T ∧ (b : A ⧸ trace.ker) = q := by
    simp_all +decide [ encoder, QuotientAddGroup.eq_iff_sub_mem ];
    rw [ sub_eq_zero, hevaluate.eq_iff ] at * ; aesop;
  exact ExistsUnique.unique ( hT q ) ⟨ hq.1, hq.2.1 ⟩ ⟨ hq.2.2.1, hq.2.2.2 ⟩

/-- A kernel transversal parametrizes every codeword, not merely a subset. -/
theorem range_encoder_restrict_transversal (trace : A →+ B) (evaluate : B → W)
    (T : Set A) (hT : IsKernelTransversal trace T) :
    Set.range (fun a : T => encoder trace evaluate a.1) =
      Set.range (encoder trace evaluate) := by
  refine' Set.ext fun x => ⟨ _, _ ⟩ <;> intro hx;
  · aesop;
  · obtain ⟨ a, rfl ⟩ := hx; specialize hT ( QuotientAddGroup.mk a ) ; cases' hT with t ht; use ⟨ t, ht.1.1 ⟩ ; simp +decide;
    simp_all +decide [ encoder, QuotientAddGroup.eq ];
    rw [ neg_add_eq_zero.mp ht.1.2 ]

/-- The refined family indexed by a transversal is in bijection with the code. -/
theorem exists_transversal_equiv_code (trace : A →+ B) (evaluate : B → W)
    (hevaluate : Function.Injective evaluate) (T : Set A)
    (hT : IsKernelTransversal trace T) :
    Nonempty (T ≃ Set.range (encoder trace evaluate)) := by
  refine' ⟨ Equiv.ofBijective _ ⟨ _, _ ⟩ ⟩;
  refine' fun x => ⟨ _, Set.mem_range_self x.val ⟩;
  · exact fun x y hxy => Subtype.ext <| encoder_injective_on_transversal trace evaluate hevaluate T hT x.2 y.2 <| Subtype.ext_iff.mp hxy;
  · intro ⟨ y, hy ⟩;
    obtain ⟨ x, rfl ⟩ := hy;
    obtain ⟨ a, ha ⟩ := hT ( QuotientAddGroup.mk x );
    simp_all +decide [ encoder, QuotientAddGroup.eq ];
    exact ⟨ a, ha.1.1, by rw [ neg_add_eq_zero.mp ha.1.2 ] ⟩

/-- Exact cardinality: a finite character-polynomial code has as many words as
there are cosets of the trace kernel. -/
theorem exact_cardinality (trace : A →+ B) (evaluate : B → W)
    (hevaluate : Function.Injective evaluate) :
    Nat.card (Set.range (encoder trace evaluate)) =
      Nat.card (A ⧸ trace.ker) := by
  rw [ ← range_quotientEncoder ];
  rw [ Nat.card_congr ( Equiv.ofInjective _ <| quotientEncoder_injective trace evaluate hevaluate ) ]

/-- A finite kernel transversal has exactly the code cardinality. -/
theorem transversal_cardinality (trace : A →+ B) (evaluate : B → W)
    (hevaluate : Function.Injective evaluate) (T : Set A)
    (hT : IsKernelTransversal trace T) :
    Nat.card T = Nat.card (Set.range (encoder trace evaluate)) := by
  obtain ⟨ e ⟩ := exists_transversal_equiv_code trace evaluate hevaluate T hT;
  exact Nat.card_congr e

end Transversal

section CoordinateFamilies

variable {ι R K W : Type*} [AddCommGroup R] [AddCommGroup K]

/-- The coefficientwise trace on a finite polynomial-support family. -/
def coefficientTrace (trace : K →+ R) : (ι → K) →+ (ι → R) where
  toFun c := fun i => trace (c i)
  map_zero' := by ext i; simp
  map_add' c d := by ext i; simp

/-- Equality of coefficient-family codewords is controlled coordinatewise by
membership in the trace kernel. -/
theorem family_encoder_eq_iff (trace : K →+ R) (evaluate : (ι → R) → W)
    (hevaluate : Function.Injective evaluate) (c d : ι → K) :
    encoder (coefficientTrace trace) evaluate c =
        encoder (coefficientTrace trace) evaluate d ↔
      ∀ i, c i - d i ∈ trace.ker := by
  convert encoder_eq_iff_sub_mem_ker ( coefficientTrace trace ) evaluate hevaluate c d using 1 ; simp +decide [ funext_iff, coefficientTrace ]

/-- The kernel of coefficientwise trace consists exactly of families whose
individual coefficients have trace zero. -/
theorem mem_coefficientTrace_ker_iff (trace : K →+ R) (c : ι → K) :
    c ∈ (coefficientTrace trace).ker ↔ ∀ i, c i ∈ trace.ker := by
  simp +decide [ coefficientTrace, AddMonoidHom.mem_ker, funext_iff ]

end CoordinateFamilies

section LinearCardinality

variable {F K R W : Type*} [Field F] [Fintype F]
  [AddCommGroup K] [Module F K] [Fintype K]
  [AddCommGroup R] [Module F R]

/-- Rank form of the exact cardinality theorem: for a linear trace-like map,
the number of distinct codewords is the field cardinality raised to the
dimension of the trace image, rather than to the dimension of the original
coefficient space. -/
theorem exact_cardinality_pow_finrank (trace : K →ₗ[F] R) (evaluate : R → W)
    (hevaluate : Function.Injective evaluate) :
    Nat.card (Set.range (encoder trace.toAddMonoidHom evaluate)) =
      Fintype.card F ^ Module.finrank F trace.range := by
  have := LinearMap.quotKerEquivRange trace;
  have := Nat.card_congr ( this.toEquiv );
  convert this using 1;
  · convert exact_cardinality trace.toAddMonoidHom evaluate hevaluate using 1;
  · have := Module.finBasis F ( LinearMap.range trace );
    have := this.repr;
    rw [ Nat.card_congr this.toEquiv ] ; simp +decide

end LinearCardinality

end CharacterPolynomialCode