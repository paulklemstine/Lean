import MachineLearning.BerggrenBranchGrowth

/-!
# Multiplicity of the stars, and the drawn picture

This file is the third cycle of the Berggren-star thread.  The previous files established
that the "strange lines and curves" of the plot are horocycles: level sets of the Lorentz
charge `−⟨v,p⟩` at a rational ideal point `p`, and that every primitive rational ideal
point carries at least one such curve (`star_at_every_primitive_ideal_point`).

Two things were left open and are settled here.

## Main results

* `IsSpokeCharge` — the predicate "`d` is the charge of a curve of the plot running into
  the ideal point of `p`", i.e. there is a sequence of admissible Pythagorean triples of
  constant charge `d` at `p` whose hypotenuse tends to infinity.  By
  `IsSpokeCharge.tendsto_dir` every such family is really drawn as a curve into `dir p`.
* `star_multiplicity_at_e1`, `star_multiplicity_at_every_tree_node`,
  `star_multiplicity_at_every_primitive_ideal_point` — **the multiplicity half of the star
  picture**: the set of spoke charges at *any* primitive rational ideal point is infinite,
  so every star has infinitely many distinct spokes.  This closes the "at least infinitely
  many curves" half of the previous cycle's Conjecture C.  The witnessing curves are
  genuine nodes of the Berggren tree: the spoke of charge `2(n+1)²` is the `mC`-orbit of
  the `n`-th node of the `mA`-branch.
* `chord_sq_ratio` — spokes of different charges are quantitatively separated: at equal
  hypotenuse the squared chordal distances to the star centre are in the exact ratio
  `d/d'`.  So distinct charges are distinct *visible* curves, not a bookkeeping artefact.
* `drawn_curve_equation`, `draw_tendsto_dir`, `drawn_radius_tendsto_one` — the picture as
  actually drawn.  If a node of hypotenuse `c` is plotted at radius `1 − 1/c` inside the
  disc rather than on the circle, then the drawn curve of charge `d` at `p` satisfies the
  exact algebraic relation `‖dir v − dir p‖² = 2d(1 − r)/c_p` between its angular and
  radial coordinates, and the drawn points still converge to the boundary point `dir p`.
  This closes the exact-relation half of the previous cycle's Conjecture E.
-/

namespace BerggrenStars

open Filter Topology

/-! ### Admissible Euclid nodes -/

/-- A Euclid pair `(m, n)` with `0 < n ≤ m` gives an admissible triple. -/
theorem adm_eu {m n : ℤ} (hn : 0 < n) (hm : n ≤ m) : Adm (eu m n) := by
  refine ⟨eu_onCone m n, ?_, ?_, ?_⟩ <;> simp only [eu] <;> nlinarith

/-! ### Spoke charges -/

/-- **A spoke of the star at `p`.**  `IsSpokeCharge p d` says that the plot contains a
family of admissible Pythagorean triples whose Lorentz charge at `p` is the constant `d`
and whose hypotenuse tends to infinity — i.e. an unbounded piece of the horocycle of
charge `d` based at the ideal point `dir p`. -/
def IsSpokeCharge (p : Vec) (d : ℤ) : Prop :=
  0 < d ∧ ∃ w : ℕ → Vec, (∀ j, Adm (w j)) ∧ (∀ j, bil (w j) p = -d) ∧
    Tendsto (fun j => ((w j).2.2 : ℝ)) atTop atTop

/-- A spoke really is drawn as a curve into the star centre. -/
theorem IsSpokeCharge.tendsto_dir {p : Vec} (hp : Adm p) {d : ℤ} (h : IsSpokeCharge p d) :
    ∃ w : ℕ → Vec, (∀ j, Adm (w j)) ∧ (∀ j, bil (w j) p = -d) ∧
      Tendsto (fun j => dirx (w j)) atTop (𝓝 (dirx p)) ∧
      Tendsto (fun j => diry (w j)) atTop (𝓝 (diry p)) := by
  obtain ⟨_, w, hadm, hch, hgr⟩ := h
  obtain ⟨hx, hy⟩ := tendsto_dir_of_constant_charge p hp.1 hp.2.2.2 w (fun j => (hadm j).1)
    (fun j => (hadm j).2.2.2) d hch hgr
  exact ⟨w, hadm, hch, hx, hy⟩

/-- The charge of a triple at a star centre is well defined, so different values of `d`
describe different families. -/
theorem charge_unique {v p : Vec} {d d' : ℤ} (hd : bil v p = -d) (hd' : bil v p = -d') :
    d = d' := by omega

/-- **Quantitative separation of the spokes.**  Two nodes of the same hypotenuse lying on
the spokes of charges `d` and `d'` are at chordal distances from the star centre whose
squares are in the exact ratio `d / d'`.  Distinct charges are therefore distinct visible
curves. -/
theorem chord_sq_ratio {v v' p : Vec} (hv : OnCone v) (hv' : OnCone v') (hp : OnCone p)
    (hvc : 0 < v.2.2) (hv'c : 0 < v'.2.2) (hpc : 0 < p.2.2) (hsame : v.2.2 = v'.2.2)
    {d d' : ℤ} (hd : bil v p = -d) (hd' : bil v' p = -d') (hd'0 : d' ≠ 0) :
    (dirx v - dirx p) ^ 2 + (diry v - diry p) ^ 2
      = ((d : ℝ) / (d' : ℝ)) * ((dirx v' - dirx p) ^ 2 + (diry v' - diry p) ^ 2) := by
  have hcR : ((v.2.2 : ℝ)) ≠ 0 := by exact_mod_cast hvc.ne'
  have hpR : ((p.2.2 : ℝ)) ≠ 0 := by exact_mod_cast hpc.ne'
  have hd'R : ((d' : ℝ)) ≠ 0 := Int.cast_ne_zero.mpr hd'0
  have hs : ((v.2.2 : ℝ)) = ((v'.2.2 : ℝ)) := by exact_mod_cast hsame
  rw [chord_of_charge hv hp hvc hpc hd, chord_of_charge hv' hp hv'c hpc hd', ← hs]
  field_simp

/-! ### An infinite supply of spokes at the ideal point `(1,0)` -/

/-- The `n`-th tree spoke: the `mC`-orbit of the `n`-th node of the `mA`-branch.  These
are genuine nodes of the Berggren tree. -/
def treeSpoke (n j : ℕ) : Vec := mC^[j] (mA^[n] root)

theorem treeSpoke_eq_eu (n j : ℕ) :
    treeSpoke n j = eu ((n : ℤ) + 2 + 2 * (j : ℤ) * ((n : ℤ) + 1)) ((n : ℤ) + 1) := by
  rw [treeSpoke, mA_iterate_root_eu, mC_iterate_eu]

theorem adm_treeSpoke (n j : ℕ) : Adm (treeSpoke n j) := by
  rw [treeSpoke_eq_eu]
  refine adm_eu (by positivity) ?_
  have hj : (0 : ℤ) ≤ (j : ℤ) := Int.natCast_nonneg j
  have hn : (0 : ℤ) ≤ (n : ℤ) := Int.natCast_nonneg n
  nlinarith

/-- Every node of the `n`-th tree spoke has charge `2(n+1)²` at the ideal point `(1,0)`. -/
theorem treeSpoke_charge (n j : ℕ) :
    bil (treeSpoke n j) (1, 0, 1) = -(2 * ((n : ℤ) + 1) ^ 2) := by
  rw [treeSpoke_eq_eu, bil_eu_e1]

/-- The hypotenuse along a tree spoke grows without bound. -/
theorem treeSpoke_hyp_ge (n j : ℕ) : (j : ℤ) ≤ (treeSpoke n j).2.2 := by
  rw [treeSpoke_eq_eu]
  simp only [eu]
  have hj : (0 : ℤ) ≤ (j : ℤ) := Int.natCast_nonneg j
  have hn : (0 : ℤ) ≤ (n : ℤ) := Int.natCast_nonneg n
  nlinarith [sq_nonneg ((j : ℤ) - 1)]

theorem treeSpoke_hyp_tendsto (n : ℕ) :
    Tendsto (fun j => ((treeSpoke n j).2.2 : ℝ)) atTop atTop := by
  apply tendsto_atTop_mono (f := fun j : ℕ => (j : ℝ))
  · intro j; exact_mod_cast treeSpoke_hyp_ge n j
  · exact tendsto_natCast_atTop_atTop

/-- For every `n` the value `2(n+1)²` is a spoke charge at the ideal point `(1,0)`. -/
theorem isSpokeCharge_e1 (n : ℕ) : IsSpokeCharge (1, 0, 1) (2 * ((n : ℤ) + 1) ^ 2) := by
  refine ⟨by positivity, fun j => treeSpoke n j, fun j => adm_treeSpoke n j,
    fun j => treeSpoke_charge n j, treeSpoke_hyp_tendsto n⟩

/-! ### Transport of a spoke by a word of the tree -/

/-- A Berggren word carries the spokes of the star at `p` to spokes of the star at the
transported point, with the same charges: the whole star is transported. -/
theorem IsSpokeCharge.transport {W : List (Vec → Vec)} (hW : IsBerggrenWord W)
    {p : Vec} {d : ℤ} (h : IsSpokeCharge p d) : IsSpokeCharge (applyWord W p) d := by
  obtain ⟨hd, w, hadm, hch, hgr⟩ := h
  refine ⟨hd, fun j => applyWord W (w j), fun j => adm_applyWord hW (hadm j), fun j => ?_, ?_⟩
  · rw [bil_applyWord hW]; exact hch j
  · apply tendsto_atTop_mono (f := fun j => ((w j).2.2 : ℝ))
    · intro j
      have := hyp_mono_applyWord hW (hadm j)
      exact_mod_cast this
    · exact hgr

/-! ### Infinite multiplicity of every star -/

private theorem two_sq_succ_injective :
    Function.Injective (fun n : ℕ => 2 * ((n : ℤ) + 1) ^ 2) := by
  intro n m h
  simp only at h
  have hn : (0 : ℤ) ≤ (n : ℤ) := Int.natCast_nonneg n
  have hm : (0 : ℤ) ≤ (m : ℤ) := Int.natCast_nonneg m
  have : (n : ℤ) = (m : ℤ) := by nlinarith
  exact_mod_cast this

/-- **Infinite multiplicity at the ideal point `(1,0)`.**  The star at `(1,0)` has
infinitely many distinct spokes, one for each charge `2n²`. -/
theorem star_multiplicity_at_e1 : {d : ℤ | IsSpokeCharge (1, 0, 1) d}.Infinite :=
  Set.infinite_of_injective_forall_mem two_sq_succ_injective isSpokeCharge_e1

/-- **Infinite multiplicity at every node of the tree.**  Transporting the star at `(1,0)`
by a word `W` shows that the ideal point of the node `W·root` carries infinitely many
distinct curves of the plot. -/
theorem star_multiplicity_at_every_tree_node {W : List (Vec → Vec)} (hW : IsBerggrenWord W) :
    {d : ℤ | IsSpokeCharge (applyWord W root) d}.Infinite := by
  have hW' : IsBerggrenWord (W ++ [mA]) := by
    intro f hf
    rcases List.mem_append.mp hf with hf' | hf'
    · exact hW f hf'
    · simp only [List.mem_singleton] at hf'
      exact Or.inl hf'
  have hpt : applyWord (W ++ [mA]) (1, 0, 1) = applyWord W root := by
    rw [applyWord_append]
    have : applyWord [mA] (1, 0, 1) = root := by
      rw [show applyWord [mA] ((1 : ℤ), (0 : ℤ), (1 : ℤ)) = mA (1, 0, 1) from rfl, mA_e1_eq_root]
    rw [this]
  refine Set.infinite_of_injective_forall_mem two_sq_succ_injective (fun n => ?_)
  have := (isSpokeCharge_e1 n).transport hW'
  rwa [hpt] at this

/-- **Infinite multiplicity at every primitive rational ideal point.**  Combining the
transport of the star with Barning–Hall completeness: every primitive Pythagorean triple
with odd first leg is the centre of a star with infinitely many distinct spokes, one for
each charge `2n²`.  This is the multiplicity statement conjectured in the previous
cycle. -/
theorem star_multiplicity_at_every_primitive_ideal_point {a b c : ℤ} (hcone : OnCone (a, b, c))
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hodd : Odd a) (hprim : Int.gcd a b = 1) :
    {d : ℤ | IsSpokeCharge (a, b, c) d}.Infinite := by
  obtain ⟨W, hW, hWeq⟩ := tree_complete hcone ha hb hc hodd hprim
  have := star_multiplicity_at_every_tree_node hW
  rwa [hWeq] at this

/-! ### The exact spectrum of the star at `(1,0)` inside the tree -/

theorem isBerggrenWord_treeWord (n j : ℕ) :
    IsBerggrenWord (List.replicate j mC ++ List.replicate n mA) := by
  intro f hf
  rcases List.mem_append.mp hf with hf' | hf'
  · exact Or.inr (Or.inr (List.eq_of_mem_replicate hf'))
  · exact Or.inl (List.eq_of_mem_replicate hf')

/-- The `n`-th tree spoke is a genuine branch of the tree: its `j`-th node is the word
`mC^j mA^n` applied to the root. -/
theorem applyWord_treeWord (n j : ℕ) :
    applyWord (List.replicate j mC ++ List.replicate n mA) root = treeSpoke n j := by
  rw [applyWord_append, applyWord_replicate, applyWord_replicate]
  rfl

/-- `d` is realised as the charge of an unbounded family of *nodes of the Berggren tree*
at the ideal point `(1,0)`: a spoke of the star that is actually drawn by the tree. -/
def IsTreeSpokeCharge (d : ℤ) : Prop :=
  0 < d ∧ ∃ w : ℕ → List (Vec → Vec), (∀ j, IsBerggrenWord (w j)) ∧
    (∀ j, bil (applyWord (w j) root) (1, 0, 1) = -d) ∧
    Tendsto (fun j => ((applyWord (w j) root).2.2 : ℝ)) atTop atTop

/-- **Exact spectrum of the star at `(1,0)`.**  The charges of the spokes drawn by the
Berggren tree at the ideal point `(1,0)` are *exactly* the numbers `2n²`, `n ≥ 1`: no
other value occurs, and every one of them occurs.  Together with `charge_spectrum` (which
bounds the charges of arbitrary primitive triples) this pins down the star completely, and
explains why the spokes look discrete: they have density zero in `ℤ`. -/
theorem tree_spoke_charge_spectrum (d : ℤ) :
    IsTreeSpokeCharge d ↔ ∃ n : ℤ, 0 < n ∧ d = 2 * n ^ 2 := by
  constructor
  · rintro ⟨-, w, hw, hch, -⟩
    obtain ⟨m', n', heq, hn', -, -⟩ :=
      eu_applyWord (hw 0) (m := 2) (n := 1) one_pos one_lt_two
    have h0 := hch 0
    rw [root_eq_eu, heq, bil_eu_e1] at h0
    exact ⟨n', hn', by omega⟩
  · rintro ⟨n, hn, rfl⟩
    obtain ⟨k, hk⟩ : ∃ k : ℕ, (k : ℤ) + 1 = n := ⟨(n - 1).toNat, by omega⟩
    refine ⟨by positivity, fun j => List.replicate j mC ++ List.replicate k mA,
      fun j => isBerggrenWord_treeWord k j, fun j => ?_, ?_⟩
    · rw [applyWord_treeWord, treeSpoke_charge, hk]
    · simpa only [applyWord_treeWord] using treeSpoke_hyp_tendsto k

/-! ### The picture as it is actually drawn -/

/-- The radius at which a node of hypotenuse `c` is drawn inside the disc. -/
noncomputable def drawnRadius (v : Vec) : ℝ := 1 - 1 / (v.2.2 : ℝ)

/-- The drawn point of a node: its ideal direction, scaled to the drawing radius. -/
noncomputable def draw (v : Vec) : ℝ × ℝ :=
  (drawnRadius v * dirx v, drawnRadius v * diry v)

/-- **Equation of the drawn curve.**  Along the spoke of charge `d` at `p` the angular
coordinate and the drawn radius `r` satisfy the exact relation
`‖dir v − dir p‖² = 2 d (1 − r) / c_p`: the drawn curve is the graph of an explicit
algebraic relation, the horocyclic one, with `d/c_p` the only parameter. -/
theorem drawn_curve_equation {v p : Vec} (hv : OnCone v) (hp : OnCone p)
    (hvc : 0 < v.2.2) (hpc : 0 < p.2.2) {d : ℤ} (hd : bil v p = -d) :
    (dirx v - dirx p) ^ 2 + (diry v - diry p) ^ 2
      = 2 * (d : ℝ) * (1 - drawnRadius v) / (p.2.2 : ℝ) := by
  have hcR : ((v.2.2 : ℝ)) ≠ 0 := by exact_mod_cast hvc.ne'
  have hpR : ((p.2.2 : ℝ)) ≠ 0 := by exact_mod_cast hpc.ne'
  rw [chord_of_charge hv hp hvc hpc hd, drawnRadius]
  field_simp
  ring

/-- The drawn radius tends to the boundary along any family whose hypotenuse blows up. -/
theorem drawn_radius_tendsto_one {w : ℕ → Vec}
    (hgr : Tendsto (fun j => ((w j).2.2 : ℝ)) atTop atTop) :
    Tendsto (fun j => drawnRadius (w j)) atTop (𝓝 1) := by
  have h0 : Tendsto (fun j => 1 / ((w j).2.2 : ℝ)) atTop (𝓝 0) :=
    Tendsto.div_atTop tendsto_const_nhds hgr
  simpa [drawnRadius] using tendsto_const_nhds.sub h0

/-- **The drawn spoke runs into the star centre.**  Even when the nodes are drawn strictly
inside the disc at radius `1 − 1/c`, a spoke of the star converges to the boundary point
`dir p`: the curve one sees in the picture really does terminate at the star centre. -/
theorem draw_tendsto_dir {p : Vec} (hp : Adm p) {d : ℤ} {w : ℕ → Vec}
    (hadm : ∀ j, Adm (w j)) (hch : ∀ j, bil (w j) p = -d)
    (hgr : Tendsto (fun j => ((w j).2.2 : ℝ)) atTop atTop) :
    Tendsto (fun j => (draw (w j)).1) atTop (𝓝 (dirx p)) ∧
      Tendsto (fun j => (draw (w j)).2) atTop (𝓝 (diry p)) := by
  obtain ⟨hx, hy⟩ := tendsto_dir_of_constant_charge p hp.1 hp.2.2.2 w (fun j => (hadm j).1)
    (fun j => (hadm j).2.2.2) d hch hgr
  have hr := drawn_radius_tendsto_one hgr
  constructor
  · simpa [draw] using hr.mul hx
  · simpa [draw] using hr.mul hy

/-- The drawn version of the multiplicity theorem: at every primitive rational ideal point
there are infinitely many charges, and the drawn curve of each of them converges to that
point. -/
theorem drawn_star_multiplicity {a b c : ℤ} (hcone : OnCone (a, b, c))
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hodd : Odd a) (hprim : Int.gcd a b = 1) :
    {d : ℤ | IsSpokeCharge (a, b, c) d}.Infinite ∧
      ∀ d ∈ {d : ℤ | IsSpokeCharge (a, b, c) d}, ∃ w : ℕ → Vec,
        (∀ j, bil (w j) (a, b, c) = -d) ∧
        Tendsto (fun j => (draw (w j)).1) atTop (𝓝 (dirx (a, b, c))) ∧
        Tendsto (fun j => (draw (w j)).2) atTop (𝓝 (diry (a, b, c))) := by
  have hadmp : Adm (a, b, c) := ⟨hcone, ha.le, hb.le, hc⟩
  refine ⟨star_multiplicity_at_every_primitive_ideal_point hcone ha hb hc hodd hprim, ?_⟩
  rintro d ⟨-, w, hadm, hch, hgr⟩
  obtain ⟨hx, hy⟩ := draw_tendsto_dir hadmp hadm hch hgr
  exact ⟨w, hch, hx, hy⟩

end BerggrenStars