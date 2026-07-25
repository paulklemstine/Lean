/-
# Gauge Invariance for Charged Tropical Distances

This file establishes a gauge-invariance theorem for charged tropical path metrics
on weighted directed graphs: exact discrete gauge fields (pure gauges) contribute
only endpoint potential shifts to path weights and tropical distances.

## Mathematical context

Given a weighted directed graph with edge weights `w : V → V → ℝ` and a gauge
potential `φ : V → ℝ`, the pure-gauge charge field `A(i,j) = φ(j) - φ(i)` is
the discrete analogue of an exact 1-form. The charged edge weight is
`w_A(i,j) = w(i,j) + A(i,j)`. The main theorem shows that for any path from
`s` to `t`, the charged path weight satisfies:

  weight_{w_A}(p) = weight_w(p) + φ(t) - φ(s)

This telescoping identity is the tropical/min-plus analogue of gauge invariance
in electromagnetic theory: exact gauge fields are cohomologically trivial for
tropical transport, affecting distances only through endpoint corrections.

## Main results

* `gaugeSum_pureGauge` — the gauge contribution along a path telescopes to
  `φ(last) - φ(first)`.
* `pathWeight_chargedWeight_pureGauge` — charged path weight = uncharged path weight
  + endpoint potential difference.
* `chargedTropicalDist_pureGauge` — the charged tropical distance satisfies
  `d_{w_A}(s,t) = d_w(s,t) + φ(t) - φ(s)`.
* `chargedTropicalDist_pureGauge_loop` — gauge invariance of loop distances:
  `d_{w_A}(v,v) = d_w(v,v)`.
* `chargedDist_eq_dist_conjugatedByPotential` — the strongest form, expressing
  charged distance as a gauge conjugation of the uncharged distance.

## Keywords

tropical gauge theory, min-plus electromagnetism, charged tropical distance,
discrete gauge invariance, graph cohomology, magnetic shortest paths,
tropical Hamilton–Jacobi, Bellman operator conjugation, exact 1-forms on graphs,
tropical transport geometry, network pricing invariance, min-plus magnetic Laplacian
-/

import Mathlib

open List

/-- Helper: a list with `length ≥ 2` is nonempty. -/
theorem ne_nil_of_length_ge_two {α : Type*} {p : List α} (hp : p.length ≥ 2) : p ≠ [] :=
  List.ne_nil_of_length_pos (by omega)

/-! ## Path weight definitions -/

/-- The weight of a path (given as a list of vertices) under edge weights `w`.
For a path `[v₀, v₁, ..., vₙ]`, the weight is `w(v₀,v₁) + w(v₁,v₂) + ... + w(vₙ₋₁,vₙ)`.
An empty or singleton list has weight 0. -/
noncomputable def pathWeight {V : Type*} (w : V → V → ℝ) : List V → ℝ
  | [] => 0
  | [_] => 0
  | a :: b :: rest => w a b + pathWeight w (b :: rest)

/-- The gauge sum of a field `A` along a path: the sum of `A(vₖ, vₖ₊₁)` over
consecutive pairs. -/
noncomputable def gaugeSum {V : Type*} (A : V → V → ℝ) : List V → ℝ
  | [] => 0
  | [_] => 0
  | a :: b :: rest => A a b + gaugeSum A (b :: rest)

/-- Charged edge weight: `w(i,j) + A(i,j)`. -/
def chargedEdgeWeight {V : Type*} (w A : V → V → ℝ) : V → V → ℝ :=
  fun i j => w i j + A i j

/-! ## Key lemmas -/

/-
Path weight distributes over addition of edge weight functions.
-/
theorem pathWeight_add {V : Type*} (w A : V → V → ℝ) (p : List V) :
    pathWeight (fun i j => w i j + A i j) p = pathWeight w p + gaugeSum A p := by
  induction' p with a p ih
  · exact left_eq_add.mpr rfl
  · cases p <;> simp_all +decide [pathWeight, gaugeSum] ; ring

/-
**Telescoping lemma**: For a pure gauge `A(i,j) = φ(j) - φ(i)`, the gauge sum
along any non-trivial path telescopes to `φ(last) - φ(first)`.
-/
theorem gaugeSum_pureGauge {V : Type*} (φ : V → ℝ) (p : List V) (hp : p.length ≥ 2) :
    gaugeSum (fun i j => φ j - φ i) p
      = φ (p.getLast (ne_nil_of_length_ge_two hp)) - φ (p.head (ne_nil_of_length_ge_two hp)) := by
  -- We proceed by induction on the length of the list `p`.
  induction' p with p ih;
  · contradiction;
  · rcases ih with ( _ | ⟨ a, _ | ⟨ b, ih ⟩ ⟩ ) <;> simp_all +decide [ gaugeSum ]

/-
**Charged path weight decomposition**: For a pure gauge field, the charged path
weight equals the uncharged path weight plus the endpoint potential difference.
-/
theorem pathWeight_chargedWeight_pureGauge {V : Type*}
    (w : V → V → ℝ) (φ : V → ℝ) (p : List V) (hp : p.length ≥ 2) :
    pathWeight (chargedEdgeWeight w (fun i j => φ j - φ i)) p
      = pathWeight w p + φ (p.getLast (ne_nil_of_length_ge_two hp))
        - φ (p.head (ne_nil_of_length_ge_two hp)) := by
  convert pathWeight_add w ( fun i j => φ j - φ i ) p using 1;
  rw [ gaugeSum_pureGauge φ p hp, add_sub_assoc ]

/-! ## Tropical distance definitions -/

/-- A path witness from `s` to `t`: a list with at least 2 elements starting at `s`
and ending at `t`. -/
structure PathWitness {V : Type*} (s t : V) where
  path : List V
  hlen : path.length ≥ 2
  hhead : path.head (ne_nil_of_length_ge_two hlen) = s
  hlast : path.getLast (ne_nil_of_length_ge_two hlen) = t

/-- The tropical (min-plus) distance from `s` to `t`: the infimum of path weights
over all paths from `s` to `t`. -/
noncomputable def tropicalDist {V : Type*} (w : V → V → ℝ) (s t : V) : ℝ :=
  iInf (fun p : PathWitness s t => pathWeight w p.path)

/-- The charged tropical distance: tropical distance under charged edge weights. -/
noncomputable def chargedTropicalDist {V : Type*} (w A : V → V → ℝ) (s t : V) : ℝ :=
  tropicalDist (chargedEdgeWeight w A) s t

/-! ## Main gauge invariance theorems -/

/-
The set of path weights from `s` to `t` is bounded below iff
the set of charged path weights from `s` to `t` is bounded below.
-/
theorem bddBelow_pathWeight_iff_charged {V : Type*}
    (w : V → V → ℝ) (φ : V → ℝ) (s t : V) :
    BddBelow (Set.range (fun p : PathWitness s t => pathWeight w p.path)) ↔
    BddBelow (Set.range (fun p : PathWitness s t =>
      pathWeight (chargedEdgeWeight w (fun i j => φ j - φ i)) p.path)) := by
  constructor <;> intro h;
  · obtain ⟨ M, hM ⟩ := h;
    refine' ⟨ M + φ t - φ s, Set.forall_mem_range.2 fun p => _ ⟩;
    have := hM ⟨ p, rfl ⟩;
    have := pathWeight_chargedWeight_pureGauge w φ p.path p.hlen; simp_all +decide ;
    rw [ p.hlast, p.hhead ] ; linarith;
  · obtain ⟨ M, hM ⟩ := h;
    use M - φ t + φ s;
    rintro _ ⟨ p, rfl ⟩;
    have := hM ⟨ p, rfl ⟩;
    have := pathWeight_chargedWeight_pureGauge w φ p.path p.hlen;
    rw [ p.hlast, p.hhead ] at this; linarith;

/-
**Charged tropical distance under pure gauge**: the charged distance equals
the uncharged distance shifted by the endpoint potential difference.

This is the central theorem: it says exact gauge fields are cohomologically
trivial for tropical transport.

The `BddBelow` hypothesis ensures that the tropical distance is well-defined
(i.e., the shortest path problem has a finite answer). This holds automatically
for finite graphs with non-negative weight cycles.
-/
theorem chargedTropicalDist_pureGauge {V : Type*}
    (w : V → V → ℝ) (φ : V → ℝ) (s t : V)
    (hbdd : BddBelow (Set.range (fun p : PathWitness s t => pathWeight w p.path))) :
    chargedTropicalDist w (fun i j => φ j - φ i) s t
      = tropicalDist w s t + φ t - φ s := by
  -- We need to show that the infimum over charged path weights is equal to the infimum over uncharged path weights plus the endpoint potential difference.
  apply le_antisymm;
  · refine' le_of_forall_pos_le_add fun ε ε0 => _;
    -- By definition of infimum, there exists a path $p$ such that $pathWeight w p.path < tropicalDist w s t + ε$.
    obtain ⟨p, hp⟩ : ∃ p : PathWitness s t, pathWeight w p.path < tropicalDist w s t + ε := by
      simpa using exists_lt_of_csInf_lt ( show Set.Nonempty ( Set.range fun p : PathWitness s t => pathWeight w p.path ) from ⟨ _, ⟨ ⟨ [ s, t ], by simp +decide, rfl, rfl ⟩, rfl ⟩ ⟩ ) ( lt_add_of_pos_right _ ε0 );
    refine' le_trans ( ciInf_le _ p ) _;
    · convert bddBelow_pathWeight_iff_charged w φ s t |>.1 hbdd using 1;
    · have := pathWeight_chargedWeight_pureGauge w φ p.path p.hlen;
      rw [ p.hhead, p.hlast ] at this ; linarith;
  · refine' le_csInf _ _;
    · exact ⟨ _, ⟨ ⟨ [ s, t ], by simp +decide, by simp +decide, by simp +decide ⟩, rfl ⟩ ⟩;
    · rintro _ ⟨ p, rfl ⟩ ; exact (by
      -- By definition of path weight, we have:
      have h_path_weight : pathWeight (chargedEdgeWeight w (fun i j => φ j - φ i)) p.path = pathWeight w p.path + φ t - φ s := by
        convert pathWeight_chargedWeight_pureGauge w φ p.path p.hlen using 1;
        rw [ p.hhead, p.hlast ];
      simp_all +decide [ tropicalDist ];
      exact ciInf_le hbdd p);

/-
**Gauge invariance of loop distances**: for pure gauge fields, the tropical
loop distance is unchanged. This is because `φ(v) - φ(v) = 0`.
-/
theorem chargedTropicalDist_pureGauge_loop {V : Type*}
    (w : V → V → ℝ) (φ : V → ℝ) (v : V)
    (hbdd : BddBelow (Set.range (fun p : PathWitness v v => pathWeight w p.path))) :
    chargedTropicalDist w (fun i j => φ j - φ i) v v
      = tropicalDist w v v := by
  convert chargedTropicalDist_pureGauge w φ v v hbdd using 1 ; ring

/-- **Gauge conjugation theorem** (strongest form): charged distance under an exact
gauge field equals conjugation of the uncharged distance by the potential.

This is the discrete tropical analogue of the statement that exact 1-forms
are cohomologically trivial: the charged semigroup is conjugate to the
uncharged one via the potential function. -/
theorem chargedDist_eq_dist_conjugatedByPotential {V : Type*}
    (w : V → V → ℝ) (φ : V → ℝ) (s t : V)
    (hbdd : BddBelow (Set.range (fun p : PathWitness s t => pathWeight w p.path))) :
    chargedTropicalDist w (fun i j => φ j - φ i) s t
      = tropicalDist w s t + φ t - φ s :=
  chargedTropicalDist_pureGauge w φ s t hbdd

/-! ## Bellman operator conjugation -/

/-- Tropical Bellman (transfer) operator: `(T_w f)(i) = ⨅ j, (w(i,j) + f(j))`. -/
noncomputable def tropicalBellman {V : Type*} [Fintype V]
    (w : V → V → ℝ) (f : V → ℝ) : V → ℝ :=
  fun i => ⨅ j : V, (w i j + f j)

/-
**Bellman operator conjugation by potential**: For a pure gauge field
`A(i,j) = φ(j) - φ(i)`, the charged Bellman operator satisfies
`T_{w+A} f = T_w (f + φ) - φ`.

This is the operator-level statement of gauge conjugation: the charged
transfer operator is conjugate to the uncharged one via the potential.
-/
theorem tropicalBellman_pureGauge_conjugation {V : Type*} [Fintype V]
    (w : V → V → ℝ) (φ : V → ℝ) (f : V → ℝ) (i : V) :
    tropicalBellman (chargedEdgeWeight w (fun i j => φ j - φ i)) f i
      = tropicalBellman w (fun j => f j + φ j) i - φ i := by
  nontriviality;
  unfold tropicalBellman chargedEdgeWeight; ring;
  simp +decide only [iInf, add_comm];
  rw [ show ( fun j => f j + ( w i j + ( φ j - φ i ) ) ) = fun j => ( φ j + ( w i j + f j ) ) - φ i by ext; ring, show ( fun j => φ j + ( w i j + f j ) ) = fun j => ( f j + ( w i j + ( φ j - φ i ) ) ) + φ i by ext; ring ] ; rw [ @csInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
  · exact ⟨ _, ⟨ i, rfl ⟩ ⟩;
  · simp +decide [add_comm, add_left_comm];
    exact fun j => csInf_le ( Set.finite_range _ |> Set.Finite.bddBelow ) ⟨ j, by ring ⟩;
  · intro x hx; rcases exists_lt_of_csInf_lt ( Set.nonempty_of_mem ( Set.mem_range_self i ) ) ( show sInf ( Set.range fun j => f j + ( w i j + ( φ j - φ i ) ) + φ i ) < x + φ i from by linarith ) with ⟨ y, ⟨ j, rfl ⟩, hy ⟩ ; exact ⟨ _, ⟨ j, rfl ⟩, by linarith ⟩ ;

/-! ## Gauge field circulation -/

/-- The circulation of a gauge field `A` around a cycle (a path that returns
to its starting point). For an exact field, this vanishes. -/
noncomputable def circulation {V : Type*} (A : V → V → ℝ) (cycle : List V) : ℝ :=
  gaugeSum A cycle

/-
**Vanishing circulation for exact fields**: A pure gauge field has zero
circulation around any cycle (a path whose first and last vertices coincide).
-/
theorem circulation_pureGauge_eq_zero {V : Type*}
    (φ : V → ℝ) (cycle : List V) (hlen : cycle.length ≥ 2)
    (hcycle : cycle.head (ne_nil_of_length_ge_two hlen)
            = cycle.getLast (ne_nil_of_length_ge_two hlen)) :
    circulation (fun i j => φ j - φ i) cycle = 0 := by
  convert gaugeSum_pureGauge φ cycle hlen using 1;
  rw [ hcycle, sub_self ]