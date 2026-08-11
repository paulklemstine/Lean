/-
# The shuffle product of series and rationality

The shuffle product of two noncommutative series is defined coefficientwise through the
unshuffle coproduct:

`(S ⧢ T | w) = Σ_{(u,v) ∈ Δ_⧢(w)} (S|u) (T|v)`.

This file proves:

* `shuffleSeries_delta` : the shuffle product of series extends the shuffle product of
  words — the shuffle of the two "Dirac" series at `u` and `v` is the series whose
  coefficient at `w` is the multiplicity of `w` in `u ⧢ v`.  This is exactly the duality
  `count_shuf_eq_count_unsh` of `Novelty.FreeMonoidUnshuffle` in action.
* `shuffleSeries_comm` : the shuffle product of series is commutative (from the
  cocommutativity of the unshuffle coproduct).
* `shuffleSeries_counit_left`, `shuffleSeries_assoc` : the counit is a unit and the
  product is associative (from coassociativity `unsh_coassoc`), so the series form a
  commutative monoid for the shuffle product.
* `isRepresentative_shuffleSeries` : **the shuffle product of two representative
  functions is representative** — the rational (Kleene–Schützenberger) series form a
  subalgebra for the shuffle product as well as for the Hadamard product.  The proof is a
  direct consequence of the bialgebra axiom `unsh_append`: the factorization of `S ⧢ T` is
  obtained by shuffling the factorizations of `S` and of `T`.
-/
import Novelty.FreeMonoidCharacters
import Novelty.RepresentativeFunctions

namespace ShuffleOfSeries

open RepresentativeFunctions FreeMonoidShuffle

variable {X K : Type*} [Field K]

/-! ## Auxiliary sum manipulations -/

lemma multiset_sum_finset_swap {ι : Type*} [Fintype ι] (M : Multiset (List X × List X))
    (F : ι → (List X × List X) → K) :
    (M.map (fun x => ∑ i, F i x)).sum = ∑ i, (M.map (F i)).sum := by
  induction M using Multiset.induction with
  | empty => simp
  | cons x M ih => simp [ih, Finset.sum_add_distrib]

lemma sum_pairMul (A B : Multiset (List X × List X)) (F : List X × List X → K) :
    ((pairMul A B).map F).sum
      = (A.map (fun al => (B.map (fun be => F (al.1 ++ be.1, al.2 ++ be.2))).sum)).sum := by
  simp [pairMul, Multiset.map_bind, Multiset.map_map, Multiset.sum_bind, Function.comp]

lemma sum_map_indicator [DecidableEq X] (x : List X × List X) (M : Multiset (List X × List X)) :
    (M.map (fun p => if p = x then (1 : K) else 0)).sum = (Multiset.count x M : K) := by
  induction M using Multiset.induction with
  | empty => simp
  | cons y M ih =>
    rw [Multiset.map_cons, Multiset.sum_cons, ih, Multiset.count_cons]
    by_cases h : y = x
    · subst h; push_cast; ring
    · simp [h, Ne.symm h]

/-! ## The shuffle product of series -/

/-- The shuffle product of two series, defined coefficientwise by the unshuffle
coproduct. -/
def shuffleSeries (f g : List X → K) : List X → K :=
  fun w => ((unsh w).map (fun p => f p.1 * g p.2)).sum

/-- The shuffle product of series is commutative, because the unshuffle coproduct is
cocommutative. -/
theorem shuffleSeries_comm (f g : List X → K) : shuffleSeries f g = shuffleSeries g f := by
  funext w
  show ((unsh w).map (fun p => f p.1 * g p.2)).sum
      = ((unsh w).map (fun p => g p.1 * f p.2)).sum
  conv_lhs => rw [← unsh_swap w]
  rw [Multiset.map_map]
  exact congrArg Multiset.sum (Multiset.map_congr rfl fun p _ => mul_comm _ _)

/-- **The shuffle of series extends the shuffle of words.**  The coefficient at `w` of the
shuffle product of the Dirac series at `u` and at `v` is the multiplicity of `w` in the
shuffle `u ⧢ v`. -/
theorem shuffleSeries_delta [DecidableEq X] (u v w : List X) :
    shuffleSeries (fun z => if z = u then (1 : K) else 0) (fun z => if z = v then 1 else 0) w
      = (Multiset.count w (shuf u v) : K) := by
  rw [count_shuf_eq_count_unsh, shuffleSeries, ← sum_map_indicator (u, v) (unsh w)]
  refine congrArg Multiset.sum (Multiset.map_congr rfl fun p _ => ?_)
  by_cases h1 : p.1 = u <;> by_cases h2 : p.2 = v <;>
    simp [h1, h2, Prod.ext_iff]

/-- **The counit is the unit of the shuffle product of series.** -/
theorem shuffleSeries_counit_left (f : List X → K) : shuffleSeries counit f = f := by
  funext w
  induction w generalizing f with
  | nil => simp [shuffleSeries, unsh]
  | cons a w ih =>
    show ((unsh (a :: w)).map (fun p => counit p.1 * f p.2)).sum = f (a :: w)
    rw [unsh_cons, Multiset.map_add, Multiset.sum_add, Multiset.map_map, Multiset.map_map]
    have h1 : ((unsh w).map
        ((fun p : List X × List X => counit p.1 * f p.2) ∘ fun p => (a :: p.1, p.2))).sum
        = (0 : K) := by
      simp [Function.comp]
    have h2 : ((unsh w).map
        ((fun p : List X × List X => counit p.1 * f p.2) ∘ fun p => (p.1, a :: p.2))).sum
        = shuffleSeries counit (fun z => f (a :: z)) w := rfl
    rw [h1, h2, ih (fun z => f (a :: z))]
    simp

/-! ## Associativity, from coassociativity of the unshuffle coproduct -/

lemma sum_coL (w : List X) (F : List X × List X × List X → K) :
    ((coL w).map F).sum
      = ((unsh w).map (fun p => ((unsh p.1).map (fun r => F (r.1, r.2, p.2))).sum)).sum := by
  simp [coL, Multiset.map_bind, Multiset.sum_bind, Multiset.map_map, Function.comp]

lemma sum_coR (w : List X) (F : List X × List X × List X → K) :
    ((coR w).map F).sum
      = ((unsh w).map (fun p => ((unsh p.2).map (fun r => F (p.1, r.1, r.2))).sum)).sum := by
  simp [coR, Multiset.map_bind, Multiset.sum_bind, Multiset.map_map, Function.comp]

/-- **The shuffle product of series is associative**, a direct consequence of the
coassociativity `unsh_coassoc` of the unshuffle coproduct. -/
theorem shuffleSeries_assoc (f g h : List X → K) :
    shuffleSeries (shuffleSeries f g) h = shuffleSeries f (shuffleSeries g h) := by
  funext w
  have hL : shuffleSeries (shuffleSeries f g) h w
      = ((coL w).map (fun t => f t.1 * g t.2.1 * h t.2.2)).sum := by
    rw [sum_coL]
    refine congrArg Multiset.sum (Multiset.map_congr rfl fun p _ => ?_)
    exact (Multiset.sum_map_mul_right).symm
  have hR : shuffleSeries f (shuffleSeries g h) w
      = ((coR w).map (fun t => f t.1 * g t.2.1 * h t.2.2)).sum := by
    rw [sum_coR]
    refine congrArg Multiset.sum (Multiset.map_congr rfl fun p _ => ?_)
    rw [show ((unsh p.2).map (fun r => f p.1 * g r.1 * h r.2))
        = ((unsh p.2).map (fun r => f p.1 * (g r.1 * h r.2))) from
      Multiset.map_congr rfl fun r _ => by ring]
    exact (Multiset.sum_map_mul_left).symm
  rw [hL, hR, unsh_coassoc]

/-! ## Rationality is preserved by the shuffle product -/

/-- **The shuffle product of two representative functions is representative.**  Together
with `RepresentativeFunctions.isRepresentative_mul` (Hadamard product) and
`isRepresentative_add`, this makes the representative functions a subalgebra of `K^{X*}`
for both products. -/
theorem isRepresentative_shuffleSeries {f g : List X → K} (hf : IsRepresentative f)
    (hg : IsRepresentative g) : IsRepresentative (shuffleSeries f g) := by
  obtain ⟨n, a, b, hab⟩ := hf
  obtain ⟨m, c, d, hcd⟩ := hg
  refine ⟨n * m,
    fun k u => shuffleSeries (a (finProdFinEquiv.symm k).1) (c (finProdFinEquiv.symm k).2) u,
    fun k v => shuffleSeries (b (finProdFinEquiv.symm k).1) (d (finProdFinEquiv.symm k).2) v,
    fun u v => ?_⟩
  rw [← finProdFinEquiv.sum_comp]
  simp only [Equiv.symm_apply_apply]
  show ((unsh (u ++ v)).map (fun p => f p.1 * g p.2)).sum = _
  rw [unsh_append, sum_pairMul]
  have step : ∀ al ∈ unsh u, ((unsh v).map (fun be => f (al.1 ++ be.1) * g (al.2 ++ be.2))).sum
      = ∑ p : Fin n × Fin m,
        (a p.1 al.1 * c p.2 al.2) * shuffleSeries (b p.1) (d p.2) v := by
    intro al _
    have hpt : ∀ be : List X × List X, f (al.1 ++ be.1) * g (al.2 ++ be.2)
        = ∑ p : Fin n × Fin m, (a p.1 al.1 * c p.2 al.2) * (b p.1 be.1 * d p.2 be.2) := by
      intro be
      rw [hab al.1 be.1, hcd al.2 be.2, Fintype.sum_prod_type, Finset.sum_mul_sum]
      exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by ring
    rw [Multiset.map_congr rfl (fun be _ => hpt be), multiset_sum_finset_swap]
    exact Finset.sum_congr rfl fun p _ => Multiset.sum_map_mul_left
  rw [Multiset.map_congr rfl step, multiset_sum_finset_swap]
  exact Finset.sum_congr rfl fun p _ => Multiset.sum_map_mul_right

end ShuffleOfSeries