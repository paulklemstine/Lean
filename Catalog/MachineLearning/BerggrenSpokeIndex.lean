import MachineLearning.BerggrenTreeCompleteness

/-!
# The spoke index of a star, and the depth at which a spoke becomes visible

The earlier files in this series explain *what* the strange curves on the hyperbolic-disc
plot of the Berggren tree are: they are horocycles, level sets of the Lorentz charge
`d = -⟨v, p⟩` at a rational ideal point `p`, and the admissible charges at the ideal point
`(1,0)` are exactly the numbers `2n²` (`charge_spectrum_odd_leg`).  So the star at `(1,0)`
has one spoke for each integer `n ≥ 1`, and `n` is the **spoke index**.

This file answers the two questions left open by that description.

## 1.  The tangency law is exact, not asymptotic (Conjecture 1 of the previous cycle)

`chord_times_hyp_eq` upgrades `chord_eq_charge` to the statement that the product

  `c_v · ‖dir v − dir p‖²`

is *literally constant* along a horocycle, equal to `2 d / c_p`.  Hence the contact of the
curve with the boundary circle is of order exactly two: `contact_order_two_lower` and
`contact_order_two_upper` show that `c_v^2 · ‖dir v − dir p‖² → ∞` while
`√c_v · ‖dir v − dir p‖² → 0`.  A radius (a geodesic through the centre) has first-order
contact, which is why the star curves look bent.

## 2.  The spoke index is the Euclid parameter, and it controls the depth
    (Conjecture 5 of the previous cycle)

Writing a triple in Euclid form `eu m n = (m² − n², 2mn, m² + n²)`, the three Berggren
generators act on the parameter pair by

  `mA : (m,n) ↦ (2m − n, m)`,  `mB : (m,n) ↦ (2m + n, m)`,  `mC : (m,n) ↦ (m + 2n, n)`,

which is the classical ternary tree on coprime pairs (`mA_eu`, `mB_eu`, `mC_eu`), and the
two boundary charges are `2n²` at `(1,0)` and `(m − n)²` at `(0,1)` (`bil_eu_e1`,
`bil_eu_e2`).  So the spoke index of a node *is* its smaller Euclid parameter.

Since each generator multiplies `m` by less than `3`, the spoke index of a node at depth
`k` satisfies `n < 2·3^k` (`spoke_index_depth_lower_bound`): the `n`-th spoke of the star
cannot appear before depth `log₃(n/2)`, so the star fills in at most logarithmically fast.
That bound is sharp up to the constant: along the hyperbolic branch `mB^k` the spoke index
is the Pell number `pell k ≥ 2^k` (`mB_iterate_root_eu`, `pell_ge_two_pow`), giving the
sandwich `2^k ≤ n < 2·3^k` at depth `k` (`spoke_index_log_sandwich`).  Along the parabolic
branch `mA^k` the index is only `k + 1` (`mA_iterate_root_eu`), the slowest possible
growth: the two Berggren regimes are visible in the star's filling rate as well as in the
approach rate.
-/

namespace BerggrenStars

open Filter Topology

/-! ### Part 1: the tangency law is an exact identity -/

/-- **Exact tangency law.**  The product of the hypotenuse of `v` with the squared chordal
distance from `dir v` to `dir p` depends only on the Lorentz charge `⟨v,p⟩` and on `p`.
Along a horocycle (constant charge) it is therefore *constant*, not merely convergent. -/
theorem chord_times_hyp_eq (v p : Vec) (hv : OnCone v) (hp : OnCone p)
    (hvc : 0 < v.2.2) (hpc : 0 < p.2.2) :
    (v.2.2 : ℝ) * ((dirx v - dirx p) ^ 2 + (diry v - diry p) ^ 2)
      = -2 * (bil v p : ℝ) / (p.2.2 : ℝ) := by
  have hc : (v.2.2 : ℝ) ≠ 0 := by exact_mod_cast hvc.ne'
  have hz : (p.2.2 : ℝ) ≠ 0 := by exact_mod_cast hpc.ne'
  rw [chord_eq_charge v p hv hp hvc hpc]
  field_simp

/-- The squared chordal distance along a horocycle of charge `d` based at `p`. -/
theorem chord_of_charge {v p : Vec} (hv : OnCone v) (hp : OnCone p)
    (hvc : 0 < v.2.2) (hpc : 0 < p.2.2) {d : ℤ} (hd : bil v p = -d) :
    (dirx v - dirx p) ^ 2 + (diry v - diry p) ^ 2
      = (2 * (d : ℝ) / (p.2.2 : ℝ)) / (v.2.2 : ℝ) := by
  rw [chord_eq_charge v p hv hp hvc hpc, hd]
  push_cast
  ring

/-- **Order-2 contact, lower half.**  Rescaling the squared distance by `c²` blows up:
the curve is not tangent to the circle to order higher than two. -/
theorem contact_order_two_lower
    (p : Vec) (hp : OnCone p) (hpc : 0 < p.2.2)
    (w : ℕ → Vec) (hw : ∀ k, OnCone (w k)) (hwc : ∀ k, 0 < (w k).2.2)
    (d : ℤ) (hd : 0 < d) (hcharge : ∀ k, bil (w k) p = -d)
    (hgrow : Tendsto (fun k => ((w k).2.2 : ℝ)) atTop atTop) :
    Tendsto (fun k => ((w k).2.2 : ℝ) ^ 2 *
        ((dirx (w k) - dirx p) ^ 2 + (diry (w k) - diry p) ^ 2)) atTop atTop := by
  have hpc' : (0 : ℝ) < (p.2.2 : ℝ) := by exact_mod_cast hpc
  have hK : (0 : ℝ) < 2 * (d : ℝ) / (p.2.2 : ℝ) := by
    have : (0 : ℝ) < (d : ℝ) := by exact_mod_cast hd
    positivity
  have hform : ∀ k, ((w k).2.2 : ℝ) ^ 2 *
      ((dirx (w k) - dirx p) ^ 2 + (diry (w k) - diry p) ^ 2)
        = (2 * (d : ℝ) / (p.2.2 : ℝ)) * ((w k).2.2 : ℝ) := by
    intro k
    have hc : ((w k).2.2 : ℝ) ≠ 0 := by exact_mod_cast (hwc k).ne'
    rw [chord_of_charge (hw k) hp (hwc k) hpc (hcharge k)]
    field_simp
  simp only [hform]
  exact Tendsto.const_mul_atTop hK hgrow

/-- **Order-2 contact, upper half.**  Rescaling by any power below one kills the distance;
together with `contact_order_two_lower` this pins the contact order at exactly two. -/
theorem contact_order_two_upper
    (p : Vec) (hp : OnCone p) (hpc : 0 < p.2.2)
    (w : ℕ → Vec) (hw : ∀ k, OnCone (w k)) (hwc : ∀ k, 0 < (w k).2.2)
    (d : ℤ) (hcharge : ∀ k, bil (w k) p = -d)
    (hgrow : Tendsto (fun k => ((w k).2.2 : ℝ)) atTop atTop) :
    Tendsto (fun k => Real.sqrt ((w k).2.2 : ℝ) *
        ((dirx (w k) - dirx p) ^ 2 + (diry (w k) - diry p) ^ 2)) atTop (𝓝 0) := by
  have hform : ∀ k, Real.sqrt ((w k).2.2 : ℝ) *
      ((dirx (w k) - dirx p) ^ 2 + (diry (w k) - diry p) ^ 2)
        = (2 * (d : ℝ) / (p.2.2 : ℝ)) / Real.sqrt ((w k).2.2 : ℝ) := by
    intro k
    have hcpos : (0 : ℝ) < ((w k).2.2 : ℝ) := by exact_mod_cast hwc k
    rw [chord_of_charge (hw k) hp (hwc k) hpc (hcharge k)]
    set s := Real.sqrt ((w k).2.2 : ℝ) with hsdef
    have hs : s ≠ 0 := by rw [hsdef]; positivity
    have hsq : ((w k).2.2 : ℝ) = s * s := (Real.mul_self_sqrt hcpos.le).symm
    rw [hsq]
    field_simp
  simp only [hform]
  exact Tendsto.div_atTop tendsto_const_nhds (Real.tendsto_sqrt_atTop.comp hgrow)

/-! ### Part 2: the Euclid parametrisation and the spoke index -/

/-- The Euclid parametrisation of a Pythagorean triple. -/
def eu (m n : ℤ) : Vec := (m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2)

theorem eu_onCone (m n : ℤ) : OnCone (eu m n) := by
  rw [eu, onCone_iff]; ring

/-- The explicit spokes of `BerggrenHorocycleStars` are Euclid pairs. -/
theorem spoke_eq_eu (n m : ℕ) : spoke n m = eu (m : ℤ) (n : ℤ) := rfl

/-- The root of the tree is the Euclid pair `(2,1)`. -/
theorem root_eq_eu : root = eu 2 1 := by decide

/-- **`mA` on Euclid parameters:** `(m,n) ↦ (2m − n, m)`. -/
theorem mA_eu (m n : ℤ) : mA (eu m n) = eu (2 * m - n) m := by
  simp only [mA, eu, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-- **`mB` on Euclid parameters:** `(m,n) ↦ (2m + n, m)`. -/
theorem mB_eu (m n : ℤ) : mB (eu m n) = eu (2 * m + n) m := by
  simp only [mB, eu, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-- **`mC` on Euclid parameters:** `(m,n) ↦ (m + 2n, n)`.  This is the generator that
fixes the spoke index, i.e. that moves a node *along* its own horocycle. -/
theorem mC_eu (m n : ℤ) : mC (eu m n) = eu (m + 2 * n) n := by
  simp only [mC, eu, Prod.mk.injEq]
  refine ⟨by ring, by ring, by ring⟩

/-- The charge at the ideal point `(1,0)` is `2n²`: the smaller Euclid parameter is the
spoke index of the star at `(1,0)`. -/
theorem bil_eu_e1 (m n : ℤ) : bil (eu m n) (1, 0, 1) = -(2 * n ^ 2) := by
  rw [bil_with_e1, eu]; ring

/-- The charge at the ideal point `(0,1)` is the odd square `(m − n)²`. -/
theorem bil_eu_e2 (m n : ℤ) : bil (eu m n) (0, 1, 1) = -((m - n) ^ 2) := by
  rw [bil_with_e2, eu]; ring

/-- The Euclid parametrisation is injective on the admissible range `0 < n < m`. -/
theorem eu_inj {m n m' n' : ℤ} (hn : 0 < n) (hm : n < m) (hn' : 0 < n') (hm' : n' < m')
    (h : eu m n = eu m' n') : m = m' ∧ n = n' := by
  simp only [eu, Prod.mk.injEq] at h
  obtain ⟨h1, -, h3⟩ := h
  have hm2 : m ^ 2 = m' ^ 2 := by linarith
  have hn2 : n ^ 2 = n' ^ 2 := by linarith
  constructor
  · nlinarith [hn.trans hm, hn'.trans hm']
  · nlinarith

/-- **Transport of the Euclid parametrisation through the tree.**  A word of length `k`
applied to the Euclid pair `(m,n)` is again a Euclid pair `(m',n')` in the admissible
range, and the larger parameter grows by a factor of at most `3^k`. -/
theorem eu_applyWord {W : List (Vec → Vec)} (hW : IsBerggrenWord W) {m n : ℤ}
    (hn : 0 < n) (hm : n < m) :
    ∃ m' n', applyWord W (eu m n) = eu m' n' ∧ 0 < n' ∧ n' < m' ∧ m' ≤ 3 ^ W.length * m := by
  induction W with
  | nil => exact ⟨m, n, rfl, hn, hm, by simp⟩
  | cons f t ih =>
      have ht : IsBerggrenWord t := fun g hg => hW g (List.mem_cons_of_mem _ hg)
      obtain ⟨m₁, n₁, heq, hn₁, hm₁, hbound⟩ := ih ht
      have hpow : (0 : ℤ) < 3 ^ t.length := by positivity
      have hlen : (f :: t).length = t.length + 1 := rfl
      have hstep : (3 : ℤ) ^ (t.length + 1) * m = 3 * (3 ^ t.length * m) := by ring
      rcases hW f (List.mem_cons_self ..) with rfl | rfl | rfl
      · refine ⟨2 * m₁ - n₁, m₁, ?_, by omega, by omega, ?_⟩
        · rw [applyWord_cons, heq, mA_eu]
        · rw [hlen, hstep]; omega
      · refine ⟨2 * m₁ + n₁, m₁, ?_, by omega, by omega, ?_⟩
        · rw [applyWord_cons, heq, mB_eu]
        · rw [hlen, hstep]; omega
      · refine ⟨m₁ + 2 * n₁, n₁, ?_, by omega, by omega, ?_⟩
        · rw [applyWord_cons, heq, mC_eu]
        · rw [hlen, hstep]; omega

/-- **The star fills in logarithmically slowly.**  If the node of the Berggren tree at the
end of a word of length `k` has Euclid pair `(m,n)` — equivalently, if it lies on the
spoke of charge `2n²` of the star at `(1,0)` — then `n < 2·3^k`.  So the spoke of index `n`
is invisible above depth `log₃(n/2)`. -/
theorem spoke_index_depth_lower_bound {W : List (Vec → Vec)} (hW : IsBerggrenWord W)
    {m n : ℤ} (hn : 0 < n) (hm : n < m) (h : applyWord W root = eu m n) :
    n < 2 * 3 ^ W.length := by
  rw [root_eq_eu] at h
  obtain ⟨m', n', heq, hn', hm', hbound⟩ := eu_applyWord hW (m := 2) (n := 1) one_pos one_lt_two
  rw [heq] at h
  obtain ⟨rfl, rfl⟩ := eu_inj hn' hm' hn hm h
  omega

/-- Restated in terms of the observable quantity: the charge of a tree node at the ideal
point `(1,0)` is `2n²` with `n` bounded by `2·3^depth`. -/
theorem charge_depth_bound {W : List (Vec → Vec)} (hW : IsBerggrenWord W)
    {m n : ℤ} (hn : 0 < n) (hm : n < m) (h : applyWord W root = eu m n) :
    bil (applyWord W root) (1, 0, 1) = -(2 * n ^ 2) ∧ n < 2 * 3 ^ W.length :=
  ⟨by rw [h, bil_eu_e1], spoke_index_depth_lower_bound hW hn hm h⟩

/-! ### The two extreme branches: parabolic (slowest) and hyperbolic (fastest) -/

/-- The parabolic branch `mA^k` has Euclid pair `(k+2, k+1)`: its spoke index grows as
slowly as possible, by exactly one per level. -/
theorem mA_iterate_root_eu (k : ℕ) : mA^[k] root = eu ((k : ℤ) + 2) ((k : ℤ) + 1) := by
  induction k with
  | zero => simpa using root_eq_eu
  | succ j ih =>
      rw [Function.iterate_succ_apply', ih, mA_eu]
      simp only [eu, Prod.mk.injEq]
      push_cast
      refine ⟨by ring, by ring, by ring⟩

/-- Pell numbers `1, 2, 5, 12, 29, 70, …`, the Euclid parameters along the hyperbolic
branch. -/
def pell : ℕ → ℤ
  | 0 => 1
  | 1 => 2
  | (k + 2) => 2 * pell (k + 1) + pell k

theorem pell_pos (k : ℕ) : 0 < pell k := by
  induction k using pell.induct with
  | case1 => norm_num [pell]
  | case2 => norm_num [pell]
  | case3 k ih1 ih2 => rw [pell]; omega

/-- The hyperbolic branch `mB^k` has Euclid pair `(pell (k+1), pell k)`: the spoke index
of the node at depth `k` on this branch is the `k`-th Pell number. -/
theorem mB_iterate_root_eu (k : ℕ) : mB^[k] root = eu (pell (k + 1)) (pell k) := by
  induction k with
  | zero => simpa [pell] using root_eq_eu
  | succ j ih =>
      rw [Function.iterate_succ_apply', ih, mB_eu]
      congr 1

/-- Pell numbers grow at least like `2^k`, so the hyperbolic branch reaches spoke index
`n` at depth at most `log₂ n`. -/
theorem pell_ge_two_pow (k : ℕ) (hk : 1 ≤ k) : (2 : ℤ) ^ k ≤ pell k := by
  induction k using pell.induct with
  | case1 => omega
  | case2 => norm_num [pell]
  | case3 j ih1 ih2 =>
      have h1 : (2 : ℤ) ^ (j + 1) ≤ pell (j + 1) := ih1 (by omega)
      have h2 : 0 < pell j := pell_pos j
      have : (2 : ℤ) ^ (j + 2) = 2 * 2 ^ (j + 1) := by ring
      rw [pell]
      omega

theorem applyWord_replicate (f : Vec → Vec) (k : ℕ) (v : Vec) :
    applyWord (List.replicate k f) v = f^[k] v := by
  induction k with
  | zero => simp
  | succ j ih =>
      rw [List.replicate_succ, applyWord_cons, ih, Function.iterate_succ_apply']

theorem isBerggrenWord_replicate_mB (k : ℕ) : IsBerggrenWord (List.replicate k mB) := by
  intro f hf
  exact Or.inr (Or.inl (List.eq_of_mem_replicate hf))

/-- **The depth bound is sharp up to the constant in the logarithm.**  At depth `k` on the
hyperbolic branch the spoke index `n` of the node satisfies `2^k ≤ n < 2·3^k`: the star's
`n`-th spoke first becomes visible at a depth of order `log n`, and no sooner. -/
theorem spoke_index_log_sandwich (k : ℕ) (hk : 1 ≤ k) :
    ∃ n : ℤ, mB^[k] root = eu (pell (k + 1)) n ∧ 2 ^ k ≤ n ∧ n < 2 * 3 ^ k ∧
      bil (mB^[k] root) (1, 0, 1) = -(2 * n ^ 2) := by
  refine ⟨pell k, mB_iterate_root_eu k, pell_ge_two_pow k hk, ?_, ?_⟩
  · have hlen : (List.replicate k mB).length = k := List.length_replicate ..
    have hpos : 0 < pell k := pell_pos k
    have hlt : pell k < pell (k + 1) := by
      induction k with
      | zero => norm_num [pell]
      | succ j _ =>
          rw [show j + 1 + 1 = j + 2 from rfl, pell]
          have := pell_pos j
          have := pell_pos (j + 1)
          omega
    have hword : applyWord (List.replicate k mB) root = eu (pell (k + 1)) (pell k) := by
      rw [applyWord_replicate]; exact mB_iterate_root_eu k
    have := spoke_index_depth_lower_bound (isBerggrenWord_replicate_mB k) hpos hlt hword
    rwa [hlen] at this
  · rw [mB_iterate_root_eu k, bil_eu_e1]

/-- **Monotonicity of the spoke index.**  `mC` leaves the spoke index unchanged (it slides
a node along its own horocycle) while `mA` and `mB` strictly increase it (they jump to an
outer spoke).  This is the combinatorial shape of the star: each spoke is an `mC`-orbit. -/
theorem spoke_index_monotone {m n : ℤ} (hn : 0 < n) (hm : n < m) :
    (∃ m', mC (eu m n) = eu m' n ∧ n < m') ∧
      (∃ m', mA (eu m n) = eu m' m ∧ n < m ∧ m < m') ∧
      (∃ m', mB (eu m n) = eu m' m ∧ n < m ∧ m < m') := by
  refine ⟨⟨m + 2 * n, mC_eu m n, by omega⟩, ⟨2 * m - n, mA_eu m n, hm, by omega⟩,
    ⟨2 * m + n, mB_eu m n, hm, by omega⟩⟩

/-- A spoke of the star at `(1,0)` really is a single `mC`-orbit: iterating `mC` from a
Euclid pair `(m,n)` keeps the index `n`, hence keeps the charge `2n²`, while the
hypotenuse `m² + n²` grows without bound. -/
theorem mC_iterate_eu (m n : ℤ) (k : ℕ) : mC^[k] (eu m n) = eu (m + 2 * (k : ℤ) * n) n := by
  induction k with
  | zero => simp
  | succ j ih =>
      rw [Function.iterate_succ_apply', ih, mC_eu]
      simp only [eu, Prod.mk.injEq]
      push_cast
      refine ⟨by ring, by ring, by ring⟩

/-- **The spoke of index `n` through a given node.**  Every node with Euclid pair `(m,n)`
lies on the spoke of charge `2n²`, and its whole `mC`-orbit stays on that spoke. -/
theorem mC_orbit_on_spoke (m n : ℤ) (k : ℕ) :
    bil (mC^[k] (eu m n)) (1, 0, 1) = -(2 * n ^ 2) := by
  rw [mC_iterate_eu, bil_eu_e1]

end BerggrenStars