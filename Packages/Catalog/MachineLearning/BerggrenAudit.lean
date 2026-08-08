import MachineLearning.BerggrenStarMultiplicity

/-! Audit file: axiom checks and numerical sanity checks for the Berggren star results. -/

open BerggrenStars

#print axioms BerggrenStars.tendsto_dir_of_constant_charge
#print axioms BerggrenStars.mC_ray_tendsto
#print axioms BerggrenStars.mA_ray_tendsto
#print axioms BerggrenStars.spoke_tangency
#print axioms BerggrenStars.mB_ray_tendsto
#print axioms BerggrenStars.berggren_rate_dichotomy
#print axioms BerggrenStars.star_centres_dense
#print axioms BerggrenStars.charge_spectrum
#print axioms BerggrenStars.star_at_every_tree_node
#print axioms BerggrenStars.tree_complete
#print axioms BerggrenStars.star_at_every_primitive_ideal_point
#print axioms BerggrenStars.chord_times_hyp_eq
#print axioms BerggrenStars.contact_order_two_lower
#print axioms BerggrenStars.contact_order_two_upper
#print axioms BerggrenStars.spoke_index_depth_lower_bound
#print axioms BerggrenStars.spoke_index_log_sandwich
#print axioms BerggrenStars.branch_growth_sandwich
#print axioms BerggrenStars.star_multiplicity_at_e1
#print axioms BerggrenStars.star_multiplicity_at_every_tree_node
#print axioms BerggrenStars.star_multiplicity_at_every_primitive_ideal_point
#print axioms BerggrenStars.chord_sq_ratio
#print axioms BerggrenStars.drawn_curve_equation
#print axioms BerggrenStars.draw_tendsto_dir
#print axioms BerggrenStars.tree_spoke_charge_spectrum
#print axioms BerggrenStars.drawn_star_multiplicity

-- numerical sanity checks
#eval (List.range 5).map fun k => mC^[k] root
#eval (List.range 5).map fun k => mA^[k] root
#eval (List.range 5).map fun k => mB^[k] root
#eval (List.range 5).map fun k => (mB^[k] root).1 - (mB^[k] root).2.1
#eval (List.range 6).map fun n => (spoke n (n + 1)).2.2 - (spoke n (n + 1)).1

/-- All charges `c - a` of primitive Pythagorean triples with odd first leg and
hypotenuse at most `N`, sorted and deduplicated. -/
def chargesUpTo (N : ℕ) : List ℕ :=
  (((List.range (N + 1)).flatMap fun a =>
      (List.range (N + 1)).filterMap fun b =>
        let s := a * a + b * b
        let c := Nat.sqrt s
        if 0 < a ∧ 0 < b ∧ c * c = s ∧ c ≤ N ∧ a % 2 = 1 ∧ Nat.gcd a b = 1 then
          some (c - a) else none).eraseDups).mergeSort (· ≤ ·)

#eval chargesUpTo 200
#eval (chargesUpTo 1000).filter (fun d => d ∈ [3, 4, 5, 6, 7, 10, 11, 12])

/-- The same scan for primitive triples with *even* first leg. -/
def chargesEvenUpTo (N : ℕ) : List ℕ :=
  (((List.range (N + 1)).flatMap fun a =>
      (List.range (N + 1)).filterMap fun b =>
        let s := a * a + b * b
        let c := Nat.sqrt s
        if 0 < a ∧ 0 < b ∧ c * c = s ∧ c ≤ N ∧ a % 2 = 0 ∧ Nat.gcd a b = 1 then
          some (c - a) else none).eraseDups).mergeSort (· ≤ ·)

#eval chargesEvenUpTo 200

-- Euclid parameters along the three pure branches, and the spoke indices they realise.
-- `mA` : index grows by one per level (slowest);  `mC` : index frozen (one spoke);
-- `mB` : index is the Pell sequence 1, 2, 5, 12, 29 (fastest, exponential).
#eval (List.range 6).map fun k => pell k
#eval (List.range 6).map fun k => (mA^[k] root, -bil (mA^[k] root) (1, 0, 1))
#eval (List.range 6).map fun k => (mC^[k] root, -bil (mC^[k] root) (1, 0, 1))
#eval (List.range 6).map fun k => (mB^[k] root, -bil (mB^[k] root) (1, 0, 1))
-- The sandwich `2^k ≤ n < 2·3^k` for the spoke index on the hyperbolic branch.
#eval (List.range 7).map fun k => (2 ^ k, pell k, 2 * 3 ^ k)

-- Mixed addresses: hypotenuse against the two-sided Lyapunov bound `5·3^{#B} ≤ c ≤ 5·7^{len}`.
#eval ([[Gen.A, Gen.B, Gen.C], [Gen.B, Gen.B, Gen.C], [Gen.C, Gen.C, Gen.C],
        [Gen.B, Gen.A, Gen.B, Gen.C]]).map fun g =>
  (5 * 3 ^ (g.count Gen.B), (applyGens g root).2.2, 5 * 7 ^ g.length)

-- Cycle 3: the spokes of the star at `(1,0)` drawn by the tree.  Row `n` is the family
-- `mC^j (mA^n root)`; the second entry of each pair is the charge `-⟨v,(1,0,1)⟩ = 2(n+1)²`,
-- constant along a row and strictly increasing down the rows.
#eval (List.range 4).map fun n =>
  (List.range 4).map fun j => (treeSpoke n j, -bil (treeSpoke n j) (1, 0, 1))
-- Distinct spokes at equal hypotenuse are separated by the exact ratio of their charges.
#eval (List.range 5).map fun n => 2 * ((n : ℤ) + 1) ^ 2