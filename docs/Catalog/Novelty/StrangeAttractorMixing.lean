import Novelty.StrangeAttractorLorenzTemplate

/-!
# Strange attractors as algebraic objects, VII: mixing and chaos

The algebraic side of the theory is now complete: the attractor is an inverse limit, its
periodic orbits are counted by traces of the transfer matrix and those counts satisfy the
Cayley–Hamilton recurrence.  This file returns to the dynamics and shows that a purely
*combinatorial* condition on the finite graph — primitivity, i.e. positivity of some power
of the transfer matrix — forces the attractor to be chaotic:

* `exists_cylinder_nbhd` : every open set of the attractor contains a cylinder around each
  of its points (the basic open sets of the inverse-limit topology);
* `topologically_mixing` : a primitive graph gives a topologically mixing shift;
* `dense_periodicPoints` : a primitive graph has periodic orbits dense in the attractor;
* `primitive_lorenzTemplate`, `primitive_prunedTemplate` : both Lorenz templates are
  primitive, hence both attractors are mixing with dense periodic orbits;
* `primitive_iff_mixing` : conversely a mixing dead-end-free attractor has a primitive
  graph, so the combinatorial and the topological conditions are equivalent;
* `sensitive_dependence` : branching graphs give sensitive dependence on initial
  conditions;
* `devaney_chaos_lorenzTemplate`, `devaney_chaos_prunedTemplate` : the resulting
  Devaney-chaos statements (transitivity + dense periodic orbits + no isolated orbits).

Primitivity is exactly the hypothesis of the Perron–Frobenius theorem for the transfer
matrix, so "chaotic" and "the transfer matrix has a dominant positive eigenvalue" are here
literally the same hypothesis.
-/

namespace LorenzLimit

variable {V : Type*} [Fintype V] [TopologicalSpace V] [DiscreteTopology V] {E : V → V → Bool}

/-! ## Cylinders -/

omit [Fintype V] [DiscreteTopology V] in
/-- The cylinder sets form a neighbourhood basis: an open subset of the attractor contains
every orbit that agrees with one of its points on a long enough initial segment. -/
theorem exists_cylinder_nbhd {U : Set (PathSpace E)} (hU : IsOpen U) {x : PathSpace E}
    (hx : x ∈ U) : ∃ m : ℕ, ∀ y : PathSpace E, (∀ k, k ≤ m → y.1 k = x.1 k) → y ∈ U := by
  rw [isOpen_induced_iff] at hU
  obtain ⟨W, hWopen, hWU⟩ := hU
  have hxW : x.1 ∈ W := by
    have : x ∈ Subtype.val ⁻¹' W := by rw [hWU]; exact hx
    exact this
  obtain ⟨I, u, hu, hIW⟩ := isOpen_pi_iff.1 hWopen x.1 hxW
  refine ⟨I.sup id, fun y hy => ?_⟩
  have hyW : y.1 ∈ W := by
    apply hIW
    intro i hi
    rw [hy i (Finset.le_sup (f := id) hi)]
    exact (hu i hi).2
  have : y ∈ Subtype.val ⁻¹' W := hyW
  rwa [hWU] at this

/-! ## Primitive graphs -/

/-- **Primitivity.**  Beyond some length every pair of vertices is joined by a walk of that
exact length; equivalently, all large powers of the transfer matrix are strictly positive. -/
def Primitive (E : V → V → Bool) : Prop :=
  ∃ N : ℕ, 0 < N ∧ ∀ n, N ≤ n → ∀ u v : V, ∃ w : ℕ → V,
    w 0 = u ∧ w n = v ∧ ∀ i, i < n → E (w i) (w (i + 1)) = true

/-! ## Mixing -/

omit [Fintype V] [DiscreteTopology V] in
/-- **Primitive graphs give topologically mixing attractors.**  For any two nonempty open
sets of orbits there is a time after which *every* iterate of the shift carries a point of
the first set into the second. -/
theorem topologically_mixing (hP : Primitive E) {U U' : Set (PathSpace E)} (hU : IsOpen U)
    (hUne : U.Nonempty) (hU' : IsOpen U') (hU'ne : U'.Nonempty) :
    ∃ N, ∀ n, N ≤ n → ∃ z ∈ U, shift^[n] z ∈ U' := by
  obtain ⟨N₀, hN₀pos, hN₀⟩ := hP
  obtain ⟨x, hxU⟩ := hUne
  obtain ⟨y, hyU'⟩ := hU'ne
  obtain ⟨m, hm⟩ := exists_cylinder_nbhd hU hxU
  obtain ⟨p, hp⟩ := exists_cylinder_nbhd hU' hyU'
  refine ⟨m + N₀, fun n hnm => ?_⟩
  have hLN : N₀ ≤ n - m := by omega
  obtain ⟨w, hw0, hwL, hwE⟩ := hN₀ (n - m) hLN (x.1 m) (y.1 0)
  set z : ℕ → V := fun k => if k ≤ m then x.1 k else if k ≤ n then w (k - m) else y.1 (k - n)
    with hz
  have hzm : ∀ k, k ≤ m → z k = x.1 k := by
    intro k hk; simp only [hz]; rw [if_pos hk]
  have hzmid : ∀ k, m < k → k ≤ n → z k = w (k - m) := by
    intro k h1 h2; simp only [hz]; rw [if_neg (by omega), if_pos h2]
  have hzlate : ∀ k, n < k → z k = y.1 (k - n) := by
    intro k h1
    have : ¬ k ≤ m := by omega
    simp only [hz]; rw [if_neg this, if_neg (by omega)]
  have hzn : z n = y.1 0 := by
    rw [hzmid n (by omega) le_rfl, hwL]
  have hzpath : ∀ k, E (z k) (z (k + 1)) = true := by
    intro k
    rcases lt_trichotomy k m with hk | hk | hk
    · rw [hzm k (by omega), hzm (k + 1) (by omega)]
      exact x.2 k
    · rw [hzm k (le_of_eq hk), hzmid (k + 1) (by omega) (by omega)]
      have h1 : k + 1 - m = 1 := by omega
      rw [h1, hk, ← hw0]
      exact hwE 0 (by omega)
    · rcases lt_trichotomy k n with hkn | hkn | hkn
      · rw [hzmid k (by omega) (by omega), hzmid (k + 1) (by omega) (by omega)]
        have h1 : k + 1 - m = (k - m) + 1 := by omega
        rw [h1]
        exact hwE (k - m) (by omega)
      · rw [hkn, hzn, hzlate (n + 1) (by omega)]
        have h1 : n + 1 - n = 1 := by omega
        rw [h1]
        exact y.2 0
      · rw [hzlate k (by omega), hzlate (k + 1) (by omega)]
        have h1 : k + 1 - n = (k - n) + 1 := by omega
        rw [h1]
        exact y.2 (k - n)
  refine ⟨⟨z, hzpath⟩, hm _ (fun k hk => hzm k hk), hp _ ?_⟩
  intro k _
  rw [shift_iterate_apply]
  show z (k + n) = y.1 k
  rcases Nat.eq_zero_or_pos k with rfl | hk
  · simpa using hzn
  · rw [hzlate (k + n) (by omega), Nat.add_sub_cancel]

/-! ## Dense periodic orbits -/

/-- Successor modulo a positive number, by cases on whether the block wraps around. -/
theorem mod_succ_cases (q k : ℕ) (hq : 0 < q) :
    (k + 1) % q = if k % q + 1 = q then 0 else k % q + 1 := by
  have hdm : q * (k / q) + k % q = k := Nat.div_add_mod k q
  have hlt : k % q < q := Nat.mod_lt k hq
  by_cases h : k % q + 1 = q
  · rw [if_pos h]
    have hk : k + 1 = q * (k / q) + q := by omega
    rw [hk, Nat.mul_add_mod, Nat.mod_self]
  · rw [if_neg h]
    have hk : k + 1 = q * (k / q) + (k % q + 1) := by omega
    rw [hk, Nat.mul_add_mod, Nat.mod_eq_of_lt (by omega)]

omit [Fintype V] [DiscreteTopology V] in
/-- **Primitive graphs have dense periodic orbits.**  Every orbit is approximated to any
precision by a periodic one. -/
theorem dense_periodicPoints (hP : Primitive E) :
    Dense {x : PathSpace E | ∃ q, 0 < q ∧ shift^[q] x = x} := by
  obtain ⟨N₀, hN₀pos, hN₀⟩ := hP
  rw [dense_iff_inter_open]
  intro U hU hUne
  obtain ⟨x, hxU⟩ := hUne
  obtain ⟨m, hm⟩ := exists_cylinder_nbhd hU hxU
  obtain ⟨w, hw0, hwL, hwE⟩ := hN₀ N₀ le_rfl (x.1 m) (x.1 0)
  set q := m + N₀ with hq
  have hqpos : 0 < q := by omega
  -- one period of the orbit: the initial segment of `x`, then the returning walk
  set base : ℕ → V := fun k => if k ≤ m then x.1 k else w (k - m) with hbase
  have hbase0 : base 0 = x.1 0 := by simp only [hbase]; rw [if_pos (Nat.zero_le _)]
  have hbaseq : base q = x.1 0 := by
    simp only [hbase]
    rw [if_neg (by omega)]
    have : q - m = N₀ := by omega
    rw [this, hwL]
  have hbasepath : ∀ k, k < q → E (base k) (base (k + 1)) = true := by
    intro k hk
    rcases lt_trichotomy k m with h | h | h
    · simp only [hbase]
      rw [if_pos (by omega), if_pos (by omega)]
      exact x.2 k
    · simp only [hbase]
      rw [if_pos (le_of_eq h), if_neg (by omega)]
      have h1 : k + 1 - m = 1 := by omega
      rw [h1, h, ← hw0]
      exact hwE 0 hN₀pos
    · simp only [hbase]
      rw [if_neg (by omega), if_neg (by omega)]
      have h1 : k + 1 - m = (k - m) + 1 := by omega
      rw [h1]
      exact hwE (k - m) (by omega)
  set z : ℕ → V := fun k => base (k % q) with hzdef
  have hzpath : ∀ k, E (z k) (z (k + 1)) = true := by
    intro k
    show E (base (k % q)) (base ((k + 1) % q)) = true
    rw [mod_succ_cases q k hqpos]
    by_cases h : k % q + 1 = q
    · rw [if_pos h, hbase0, ← hbaseq]
      have hstep := hbasepath (k % q) (Nat.mod_lt k hqpos)
      rwa [h] at hstep
    · rw [if_neg h]
      exact hbasepath (k % q) (Nat.mod_lt k hqpos)
  refine ⟨⟨z, hzpath⟩, hm _ ?_, ⟨q, hqpos, ?_⟩⟩
  · intro k hk
    show base (k % q) = x.1 k
    rw [Nat.mod_eq_of_lt (by omega)]
    simp only [hbase]
    rw [if_pos hk]
  · apply Subtype.ext
    funext k
    rw [shift_iterate_apply]
    show base ((k + q) % q) = base (k % q)
    rw [Nat.add_mod_right]

/-! ## Both Lorenz templates are primitive -/

theorem primitive_lorenzTemplate : Primitive lorenzTemplate := by
  refine ⟨1, Nat.one_pos, fun n hn u v =>
    ⟨fun k => if k = 0 then u else v, ?_, ?_, fun _ _ => rfl⟩⟩
  · simp
  · have hn0 : n ≠ 0 := by omega
    simp [hn0]

theorem primitive_prunedTemplate : Primitive prunedTemplate := by
  refine ⟨2, by norm_num, fun n hn u v =>
    ⟨fun k => if k = 0 then u else if k = n then v else false, ?_, ?_, ?_⟩⟩
  · simp
  · have hn0 : n ≠ 0 := by omega
    simp [hn0]
  · intro i hi
    by_cases h : i + 1 = n
    · have hi0 : i ≠ 0 := by omega
      have hin : i ≠ n := by omega
      simp [hi0, hin, h, prunedTemplate]
    · simp [h, prunedTemplate]

/-! ## The converse: mixing forces primitivity -/

omit [Fintype V] in
/-- The cylinder of orbits starting at a given vertex is open. -/
theorem isOpen_startCylinder (u : V) : IsOpen {x : PathSpace E | x.1 0 = u} := by
  have hcont : Continuous (fun x : PathSpace E => x.1 0) :=
    (continuous_apply 0).comp continuous_subtype_val
  exact hcont.isOpen_preimage {u} (isOpen_discrete _)

omit [Fintype V] [TopologicalSpace V] [DiscreteTopology V] in
theorem startCylinder_nonempty (hE : NoDeadEnds E) (u : V) :
    ({x : PathSpace E | x.1 0 = u}).Nonempty :=
  ⟨⟨deadEndFreeSeq hE u, fun n => (hE (deadEndFreeSeq hE u n)).choose_spec⟩, rfl⟩

/-- **Mixing forces primitivity.**  Together with `topologically_mixing` this makes the
combinatorial condition on the finite graph and the topological condition on the attractor
equivalent, for any dead-end-free graph. -/
theorem primitive_of_mixing (hE : NoDeadEnds E)
    (hmix : ∀ {U U' : Set (PathSpace E)}, IsOpen U → U.Nonempty → IsOpen U' → U'.Nonempty →
      ∃ N, ∀ n, N ≤ n → ∃ z ∈ U, shift^[n] z ∈ U') :
    Primitive E := by
  choose Nf hNf using fun p : V × V =>
    hmix (isOpen_startCylinder p.1) (startCylinder_nonempty hE p.1)
      (isOpen_startCylinder p.2) (startCylinder_nonempty hE p.2)
  refine ⟨Finset.univ.sup Nf + 1, Nat.succ_pos _, fun n hn u v => ?_⟩
  have hle : Nf (u, v) ≤ n :=
    le_trans (le_trans (Finset.le_sup (Finset.mem_univ (u, v))) (Nat.le_succ _)) hn
  obtain ⟨z, hz1, hz2⟩ := hNf (u, v) n hle
  refine ⟨z.1, hz1, ?_, fun i _ => z.2 i⟩
  have : (shift^[n] z).1 0 = v := hz2
  rwa [shift_iterate_apply, Nat.zero_add] at this

/-- **Primitivity is exactly mixing** for dead-end-free graphs. -/
theorem primitive_iff_mixing (hE : NoDeadEnds E) :
    Primitive E ↔ ∀ {U U' : Set (PathSpace E)}, IsOpen U → U.Nonempty → IsOpen U' →
      U'.Nonempty → ∃ N, ∀ n, N ≤ n → ∃ z ∈ U, shift^[n] z ∈ U' :=
  ⟨fun hP _ _ hU hUne hU' hU'ne => topologically_mixing hP hU hUne hU' hU'ne,
    fun hmix => primitive_of_mixing hE hmix⟩

/-! ## Sensitive dependence on initial conditions -/

omit [Fintype V] [DiscreteTopology V] in
/-- **Sensitive dependence on initial conditions.**  If every vertex branches, then
arbitrarily close to any orbit there is another orbit whose future separates from it: some
iterate of the shift sends the two orbits to points with different `0`-th coordinates,
which in the discrete topology of `V` is a macroscopic separation. -/
theorem sensitive_dependence (h : Branching E) (x : PathSpace E) {U : Set (PathSpace E)}
    (hU : IsOpen U) (hx : x ∈ U) :
    ∃ y ∈ U, ∃ k, (shift^[k] y).1 0 ≠ (shift^[k] x).1 0 := by
  obtain ⟨m, hm⟩ := exists_cylinder_nbhd hU hx
  refine ⟨altPath h x m, hm _ (fun k hk => altPath_agree h x m hk), m + 1, ?_⟩
  rw [shift_iterate_apply, shift_iterate_apply]
  simpa using altPath_ne h x m

/-- The Lorenz template attractor depends sensitively on initial conditions. -/
theorem sensitive_dependence_lorenzTemplate (x : PathSpace lorenzTemplate)
    {U : Set (PathSpace lorenzTemplate)} (hU : IsOpen U) (hx : x ∈ U) :
    ∃ y ∈ U, ∃ k, (shift^[k] y).1 0 ≠ (shift^[k] x).1 0 :=
  sensitive_dependence branching_lorenzTemplate x hU hx

/-! ## Devaney chaos for the Lorenz template attractor -/

/-- **The Lorenz template attractor is chaotic**: the shift is topologically mixing (hence
transitive) and its periodic orbits are dense. -/
theorem devaney_chaos_lorenzTemplate :
    (∀ {U U' : Set (PathSpace lorenzTemplate)}, IsOpen U → U.Nonempty → IsOpen U' →
        U'.Nonempty → ∃ N, ∀ n, N ≤ n → ∃ z ∈ U, shift^[n] z ∈ U')
      ∧ Dense {x : PathSpace lorenzTemplate | ∃ q, 0 < q ∧ shift^[q] x = x} :=
  ⟨fun hU hUne hU' hU'ne =>
      topologically_mixing primitive_lorenzTemplate hU hUne hU' hU'ne,
    dense_periodicPoints primitive_lorenzTemplate⟩

/-- The pruned template attractor is chaotic as well: pruning changes the entropy but not
the qualitative dynamics. -/
theorem devaney_chaos_prunedTemplate :
    (∀ {U U' : Set (PathSpace prunedTemplate)}, IsOpen U → U.Nonempty → IsOpen U' →
        U'.Nonempty → ∃ N, ∀ n, N ≤ n → ∃ z ∈ U, shift^[n] z ∈ U')
      ∧ Dense {x : PathSpace prunedTemplate | ∃ q, 0 < q ∧ shift^[q] x = x} :=
  ⟨fun hU hUne hU' hU'ne =>
      topologically_mixing primitive_prunedTemplate hU hUne hU' hU'ne,
    dense_periodicPoints primitive_prunedTemplate⟩

end LorenzLimit