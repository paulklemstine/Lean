import Pythagorean.PTripleMonoid

/-!
# The aggregate dichotomy for families of Pythagorean triples

Given a finite *family* of Pythagorean triples `f : Fin n → PTriple` there are two natural
ways of compressing it into a single object.

* the **unlabeled product** `uprod f = ∏ i, f i`, formed with the Brahmagupta–Fibonacci
  (Gaussian) product of `Pythagorean.PTripleMonoid`;
* the **interleaved aggregate** `interleave f`, a single natural number obtained by
  interleaving the coordinate streams of the members through the Cantor pairing function.

The results below give a sharp dichotomy between the two.

## Main results

* `Pythagorean.uprod_perm_invariant` : the product only sees the *unordered* family.
* `Pythagorean.no_injective_symmetric_aggregate` : **structural obstruction** — for `n ≥ 2`
  *no* permutation-invariant aggregate whatsoever (into any target type) can be injective.
  This explains the failure of `uprod` conceptually, not by accident of the definition.
* `Pythagorean.uprod_not_injective` : hence `uprod` is not injective for `n ≥ 2`.
* `Pythagorean.multiset_prod_not_injective` : the failure is *not only* the loss of order —
  even the induced map on multisets is non-injective.  Witness (Gaussian squares):
  `{(-7,24,25), (-119,120,169)}` and `{(-33,56,65), (-33,56,65)}` are distinct multisets of
  Pythagorean triples with the same product `(-2047,-3696,4225)`.
* `Pythagorean.uprod_fiber_one_ncard` : the fibre of `uprod` over the identity triple for
  `n = 2` has *exactly four* elements, coming from the four rotations `±1, ±i`; so `uprod`
  is at least `4`-to-`1`.
* `Pythagorean.interleave_injective` : the interleaved aggregate is injective for every `n`.
* `Pythagorean.uprod_factors_through_interleave` and
  `Pythagorean.interleave_not_factors_through_uprod` : the interleaved aggregate is a
  *strict* refinement of the product.
-/

namespace Pythagorean

open PTriple

/-! ## The unlabeled product -/

/-- The unlabeled product of a finite family of Pythagorean triples. -/
def uprod {n : ℕ} (f : Fin n → PTriple) : PTriple := ∏ i, f i

@[simp] lemma uprod_zero (f : Fin 0 → PTriple) : uprod f = 1 := by
  simp [uprod]

lemma uprod_two (f : Fin 2 → PTriple) : uprod f = f 0 * f 1 := by
  simp [uprod, Fin.prod_univ_two]

/-- The hypotenuse of the product is the product of the hypotenuses. -/
lemma uprod_c {n : ℕ} (f : Fin n → PTriple) : (uprod f).c = ∏ i, (f i).c :=
  c_prod f

/-- **The unlabeled product only sees the unordered family.** -/
theorem uprod_perm_invariant {n : ℕ} (σ : Equiv.Perm (Fin n)) (f : Fin n → PTriple) :
    uprod (f ∘ σ) = uprod f :=
  Equiv.prod_comp σ f

/-! ## Two concrete triples and their Gaussian squares -/

/-- The triple `(3,4,5)`, i.e. the Gaussian integer `3 + 4i`. -/
def t345 : PTriple := ofLegs 3 4 5 (by norm_num) (by norm_num)

/-- The triple `(5,12,13)`, i.e. the Gaussian integer `5 + 12i`. -/
def t51213 : PTriple := ofLegs 5 12 13 (by norm_num) (by norm_num)

/-- `(3+4i)² = -7 + 24i`. -/
def tA : PTriple := ofLegs (-7) 24 25 (by norm_num) (by norm_num)

/-- `(5+12i)² = -119 + 120i`. -/
def tB : PTriple := ofLegs (-119) 120 169 (by norm_num) (by norm_num)

/-- `(3+4i)(5+12i) = -33 + 56i`. -/
def tC : PTriple := ofLegs (-33) 56 65 (by norm_num) (by norm_num)

lemma t345_ne_one : t345 ≠ 1 := by
  intro h
  have : (3 : ℤ) = 1 := by simpa [t345] using congrArg PTriple.a h
  norm_num at this

lemma tA_ne_tC : tA ≠ tC := by
  intro h
  have : (-7 : ℤ) = -33 := by simpa [tA, tC] using congrArg PTriple.a h
  norm_num at this

lemma tB_ne_tC : tB ≠ tC := by
  intro h
  have : (-119 : ℤ) = -33 := by simpa [tB, tC] using congrArg PTriple.a h
  norm_num at this

/-- The Gaussian identity `(3+4i)² · (5+12i)² = ((3+4i)(5+12i))²` at the level of triples. -/
theorem tA_mul_tB_eq_tC_mul_tC : tA * tB = tC * tC := by
  ext <;> simp [tA, tB, tC]

/-! ## Failure of injectivity for the unlabeled product -/

/-- **Structural obstruction.**  For families of length at least two, *no* aggregate that is
invariant under permuting the family can be injective — whatever its target type.  The
unlabeled product is one instance of this obstruction. -/
theorem no_injective_symmetric_aggregate {β : Type*} {n : ℕ} (hn : 2 ≤ n)
    (F : (Fin n → PTriple) → β)
    (hsymm : ∀ (σ : Equiv.Perm (Fin n)) (f : Fin n → PTriple), F (f ∘ σ) = F f) :
    ¬ Function.Injective F := by
  intro hinj
  have h0 : (0 : ℕ) < n := by omega
  have h1 : (1 : ℕ) < n := by omega
  set i0 : Fin n := ⟨0, h0⟩ with hi0
  set i1 : Fin n := ⟨1, h1⟩ with hi1
  have hne : i0 ≠ i1 := by
    simp [hi0, hi1, Fin.ext_iff]
  classical
  set f : Fin n → PTriple := fun i => if i = i0 then t345 else 1 with hf
  have hswap : f ∘ (Equiv.swap i0 i1) = f := hinj (hsymm (Equiv.swap i0 i1) f)
  have := congrFun hswap i0
  simp only [Function.comp_apply, Equiv.swap_apply_left, hf, if_neg hne.symm, if_pos rfl] at this
  exact t345_ne_one this.symm

/-- **The unlabeled product is not injective on families** of length `≥ 2`. -/
theorem uprod_not_injective {n : ℕ} (hn : 2 ≤ n) :
    ¬ Function.Injective (uprod (n := n)) :=
  no_injective_symmetric_aggregate hn _ uprod_perm_invariant

/-- **The failure survives passage to multisets.**  Forgetting the order is not the only
information lost: two genuinely different *unordered* families of Pythagorean triples can
have the same Brahmagupta product, because a Gaussian integer can factor in essentially
different ways inside the square-norm monoid. -/
theorem multiset_prod_not_injective :
    ¬ Function.Injective (Multiset.prod : Multiset PTriple → PTriple) := by
  intro hinj
  have hprod : ({tA, tB} : Multiset PTriple).prod = ({tC, tC} : Multiset PTriple).prod := by
    simp only [Multiset.insert_eq_cons, Multiset.prod_cons, Multiset.prod_singleton]
    exact tA_mul_tB_eq_tC_mul_tC
  have hset := hinj hprod
  have hmem : tA ∈ ({tC, tC} : Multiset PTriple) := by
    rw [← hset]; simp
  rcases Multiset.mem_cons.mp hmem with h | h
  · exact tA_ne_tC h
  · exact tA_ne_tC (Multiset.mem_singleton.mp h)

/-! ## The exact size of the fibre over the identity -/

/-- The rotation `i = (0,1,1)`. -/
def rotI : PTriple := ofLegs 0 1 1 (by norm_num) (by norm_num)

/-- The rotation `-i = (0,-1,1)`. -/
def rotNegI : PTriple := ofLegs 0 (-1) 1 (by norm_num) (by norm_num)

/-- The rotation `-1 = (-1,0,1)`. -/
def rotNegOne : PTriple := ofLegs (-1) 0 1 (by norm_num) (by norm_num)

private lemma vec_ne {x y z w : PTriple} (h : x ≠ z) : ![x, y] ≠ ![z, w] := by
  intro he
  exact h (by simpa using congrFun he 0)

/-- The fibre of the length-two product over the identity triple consists of exactly the
four pairs of mutually inverse rotations. -/
theorem uprod_fiber_one_eq :
    {f : Fin 2 → PTriple | uprod f = 1} =
      {![1, 1], ![rotNegOne, rotNegOne], ![rotI, rotNegI], ![rotNegI, rotI]} := by
  ext f
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff, uprod_two]
  constructor
  · intro h
    -- both hypotenuses are `1`
    have hc : (f 0).c * (f 1).c = 1 := by simpa using congrArg PTriple.c h
    have hc0 : (f 0).c = 1 := by
      have hu := Int.isUnit_iff.mp (IsUnit.of_mul_eq_one (f 1).c hc)
      have h0 := (f 0).hc
      omega
    have hc1 : (f 1).c = 1 := by
      have hc' : (f 1).c * (f 0).c = 1 := by rw [mul_comm]; exact hc
      have hu := Int.isUnit_iff.mp (IsUnit.of_mul_eq_one (f 0).c hc')
      have h0 := (f 1).hc
      omega
    have ha : (f 0).a * (f 1).a - (f 0).b * (f 1).b = 1 := by
      simpa using congrArg PTriple.a h
    have hb : (f 0).a * (f 1).b + (f 0).b * (f 1).a = 0 := by
      simpa using congrArg PTriple.b h
    have key : ∀ x y : PTriple, x.a = (f 0).a → x.b = (f 0).b → x.c = (f 0).c →
        y.a = (f 1).a → y.b = (f 1).b → y.c = (f 1).c → ![x, y] = f := by
      intro x y h1 h2 h3 h4 h5 h6
      funext i
      fin_cases i
      · exact PTriple.ext h1 h2 h3
      · exact PTriple.ext h4 h5 h6
    rcases eq_of_c_eq_one (f 0) hc0 with ⟨p, q⟩ | ⟨p, q⟩ | ⟨p, q⟩ | ⟨p, q⟩
    · -- f 0 = 1
      left
      refine (key 1 1 (by simp [p]) (by simp [q]) (by simp [hc0]) ?_ ?_ (by simp [hc1])).symm
      · rw [p, q] at ha; simpa using ha.symm
      · rw [p, q] at hb; simpa using hb.symm
    · -- f 0 = -1
      right; left
      refine (key rotNegOne rotNegOne (by simp [rotNegOne, p]) (by simp [rotNegOne, q])
        (by simp [rotNegOne, hc0]) ?_ ?_ (by simp [rotNegOne, hc1])).symm
      · rw [p, q] at ha; simp only [rotNegOne, ofLegs_a]; linarith
      · rw [p, q] at hb; simp only [rotNegOne, ofLegs_b]; linarith
    · -- f 0 = i
      right; right; left
      refine (key rotI rotNegI (by simp [rotI, p]) (by simp [rotI, q]) (by simp [rotI, hc0])
        ?_ ?_ (by simp [rotNegI, hc1])).symm
      · rw [p, q] at hb; simp only [rotNegI, ofLegs_a]; linarith
      · rw [p, q] at ha; simp only [rotNegI, ofLegs_b]; linarith
    · -- f 0 = -i
      right; right; right
      refine (key rotNegI rotI (by simp [rotNegI, p]) (by simp [rotNegI, q])
        (by simp [rotNegI, hc0]) ?_ ?_ (by simp [rotI, hc1])).symm
      · rw [p, q] at hb; simp only [rotI, ofLegs_a]; linarith
      · rw [p, q] at ha; simp only [rotI, ofLegs_b]; linarith
  · rintro (rfl | rfl | rfl | rfl) <;>
      · ext <;> simp [rotI, rotNegI, rotNegOne]

/-- **The product is exactly four-to-one over the identity**: the four rotations `±1, ±i`
of the Gaussian unit group are the whole source of the collision. -/
theorem uprod_fiber_one_ncard :
    Set.ncard {f : Fin 2 → PTriple | uprod f = 1} = 4 := by
  have h1 : ((1 : PTriple)) ≠ rotNegOne := by
    intro h
    have : (1 : ℤ) = -1 := by simpa [rotNegOne] using congrArg PTriple.a h
    norm_num at this
  have h2 : ((1 : PTriple)) ≠ rotI := by
    intro h
    have : (1 : ℤ) = 0 := by simpa [rotI] using congrArg PTriple.a h
    norm_num at this
  have h3 : ((1 : PTriple)) ≠ rotNegI := by
    intro h
    have : (1 : ℤ) = 0 := by simpa [rotNegI] using congrArg PTriple.a h
    norm_num at this
  have h4 : rotNegOne ≠ rotI := by
    intro h
    have : (-1 : ℤ) = 0 := by simpa [rotNegOne, rotI] using congrArg PTriple.a h
    norm_num at this
  have h5 : rotNegOne ≠ rotNegI := by
    intro h
    have : (-1 : ℤ) = 0 := by simpa [rotNegOne, rotNegI] using congrArg PTriple.a h
    norm_num at this
  have h6 : rotI ≠ rotNegI := by
    intro h
    have : (1 : ℤ) = -1 := by simpa [rotI, rotNegI] using congrArg PTriple.b h
    norm_num at this
  rw [uprod_fiber_one_eq]
  rw [Set.ncard_insert_of_notMem (by
        simp only [Set.mem_insert_iff, Set.mem_singleton_iff]
        push_neg
        exact ⟨vec_ne h1, vec_ne h2, vec_ne h3⟩),
      Set.ncard_insert_of_notMem (by
        simp only [Set.mem_insert_iff, Set.mem_singleton_iff]
        push_neg
        exact ⟨vec_ne h4, vec_ne h5⟩),
      Set.ncard_insert_of_notMem (by
        simp only [Set.mem_singleton_iff]
        exact vec_ne h6),
      Set.ncard_singleton]

/-! ## The interleaved aggregate -/

/-- A single Pythagorean triple, encoded as a natural number through its legs.  The
hypotenuse may be dropped because it is determined by the legs (`PTriple.c_eq_of_legs`). -/
def encodeTriple (t : PTriple) : ℕ :=
  Nat.pair (Encodable.encode t.a) (Encodable.encode t.b)

theorem encodeTriple_injective : Function.Injective encodeTriple := by
  intro t s h
  obtain ⟨h1, h2⟩ := Nat.pair_eq_pair.mp h
  have ha : t.a = s.a := Encodable.encode_injective h1
  have hb : t.b = s.b := Encodable.encode_injective h2
  exact PTriple.ext ha hb (c_eq_of_legs ha hb)

/-- The **interleaved aggregate** of a family of Pythagorean triples: the coordinate streams
of the members are interleaved into a single natural number by iterated Cantor pairing. -/
def interleave : ∀ {n : ℕ}, (Fin n → PTriple) → ℕ
  | 0, _ => 0
  | _ + 1, f => Nat.pair (encodeTriple (f 0)) (interleave (Fin.tail f))

@[simp] lemma interleave_zero (f : Fin 0 → PTriple) : interleave f = 0 := rfl

@[simp] lemma interleave_succ {n : ℕ} (f : Fin (n + 1) → PTriple) :
    interleave f = Nat.pair (encodeTriple (f 0)) (interleave (Fin.tail f)) := rfl

/-- **The interleaved aggregate is injective**: unlike the product, it remembers both the
members of the family and their labels. -/
theorem interleave_injective : ∀ {n : ℕ}, Function.Injective (interleave (n := n))
  | 0 => by
      intro f g _
      funext i
      exact absurd i.isLt (by omega)
  | n + 1 => by
      intro f g h
      rw [interleave_succ, interleave_succ] at h
      obtain ⟨h1, h2⟩ := Nat.pair_eq_pair.mp h
      have hhead : f 0 = g 0 := encodeTriple_injective h1
      have htail : Fin.tail f = Fin.tail g := interleave_injective h2
      calc f = Fin.cons (f 0) (Fin.tail f) := (Fin.cons_self_tail f).symm
        _ = Fin.cons (g 0) (Fin.tail g) := by rw [hhead, htail]
        _ = g := Fin.cons_self_tail g

/-! ## The dichotomy, and strict refinement -/

/-- **Aggregate dichotomy.**  For families of length at least two the unlabeled product is
not injective, while the interleaved aggregate always is. -/
theorem aggregate_dichotomy {n : ℕ} (hn : 2 ≤ n) :
    ¬ Function.Injective (uprod (n := n)) ∧ Function.Injective (interleave (n := n)) :=
  ⟨uprod_not_injective hn, interleave_injective⟩

/-- The product is recoverable from the interleaved aggregate. -/
theorem uprod_factors_through_interleave {n : ℕ} :
    ∃ ψ : ℕ → PTriple, ∀ f : Fin n → PTriple, uprod f = ψ (interleave f) := by
  classical
  refine ⟨fun m => uprod (Function.invFun (interleave (n := n)) m), fun f => ?_⟩
  exact congrArg uprod (Function.leftInverse_invFun interleave_injective f).symm

/-- The interleaved aggregate is *not* recoverable from the product: the refinement is
strict as soon as the family has length at least two. -/
theorem interleave_not_factors_through_uprod {n : ℕ} (hn : 2 ≤ n) :
    ¬ ∃ ψ : PTriple → ℕ, ∀ f : Fin n → PTriple, interleave f = ψ (uprod f) := by
  rintro ⟨ψ, hψ⟩
  refine uprod_not_injective hn ?_
  intro f g h
  exact interleave_injective (by rw [hψ f, hψ g, h])

end Pythagorean