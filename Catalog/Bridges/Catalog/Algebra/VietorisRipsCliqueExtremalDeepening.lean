import Mathlib

/-!
# Rigidity of the extremal Vietoris–Rips clique count

The elementary bound saying that a graph on `n` vertices has at most `2^n` cliques
leaves open its equality case.  This file proves the sharp rigidity statement for every
finite vertex type: a graph has as many cliques as subsets if and only if it is complete.
It also derives strict monotonicity of clique-complex size when an edge is added, and a
metric consequence: a Vietoris–Rips complex has maximal size exactly when every pair is
within the scale.
-/

noncomputable section

open Classical Finset

namespace VRCliqueExtremalDeepening

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The finite clique complex of a graph on an arbitrary finite vertex type. -/
def cliqueFamily (H : SimpleGraph α) : Finset (Finset α) :=
  Finset.univ.powerset.filter fun S => H.IsClique (↑S : Set α)

/-- Membership in the finite clique complex is precisely the graph-theoretic clique
predicate. -/
theorem mem_cliqueFamily (H : SimpleGraph α) (S : Finset α) :
    S ∈ cliqueFamily H ↔ H.IsClique (↑S : Set α) := by
  unfold cliqueFamily; aesop;

/-- Every graph has at most `2 ^ |α|` cliques. -/
theorem card_cliqueFamily_le (H : SimpleGraph α) :
    (cliqueFamily H).card ≤ 2 ^ Fintype.card α := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by simp +decide [ Finset.card_univ ] )

/-- The complete graph has every subset as a clique. -/
theorem cliqueFamily_top :
    cliqueFamily (⊤ : SimpleGraph α) = Finset.univ.powerset := by
  ext S;
  simp +decide [ mem_cliqueFamily, Set.Pairwise ]

/-- **Extremal rigidity.** A graph on a finite vertex type has the maximum possible
number of cliques if and only if it is complete. -/
theorem card_cliqueFamily_eq_two_pow_iff (H : SimpleGraph α) :
    (cliqueFamily H).card = 2 ^ Fintype.card α ↔ H = ⊤ := by
  constructor;
  · intro h_card
    have h_eq : cliqueFamily H = Finset.univ.powerset := by
      exact Finset.eq_of_subset_of_card_le ( Finset.filter_subset _ _ ) ( by simp +decide [ h_card ] );
    ext x y; by_cases hxy : x = y <;> simp_all +decide ;
    replace h_eq := Finset.ext_iff.mp h_eq { x, y } ; simp_all +decide [ cliqueFamily ] ;
  · rintro rfl; rw [ cliqueFamily_top ] ; simp +decide [ Finset.card_univ ] ;

/-- Consequently every non-complete graph has strictly fewer than `2 ^ |α|` cliques. -/
theorem card_cliqueFamily_lt_of_ne_top (H : SimpleGraph α) (hH : H ≠ ⊤) :
    (cliqueFamily H).card < 2 ^ Fintype.card α := by
  contrapose! hH;
  exact card_cliqueFamily_eq_two_pow_iff H |>.1 ( le_antisymm ( card_cliqueFamily_le H ) hH ) ▸ rfl

/-- Adding graph edges can only add simplices to the clique complex. -/
theorem cliqueFamily_mono {G H : SimpleGraph α} (hGH : G ≤ H) :
    cliqueFamily G ⊆ cliqueFamily H := by
  intro S hS; rw [ mem_cliqueFamily ] at hS; rw [ mem_cliqueFamily ] ; refine' hS.mono fun x => _; aesop;

/-- Adding at least one edge strictly increases the number of cliques. -/
theorem card_cliqueFamily_strictMono {G H : SimpleGraph α} (hGH : G < H) :
    (cliqueFamily G).card < (cliqueFamily H).card := by
  -- From G<H obtain an edge i-j of H absent in G.
  obtain ⟨i, j, hij, hG⟩ : ∃ i j, i ≠ j ∧ H.Adj i j ∧ ¬G.Adj i j := by
    contrapose! hGH;
    exact fun h => h.not_ge fun u v => by by_cases huv : u = v <;> aesop;
  refine' Finset.card_lt_card ( Finset.ssubset_iff_subset_ne.2 ⟨ _, _ ⟩ );
  · exact cliqueFamily_mono hGH.le;
  · intro h; have := mem_cliqueFamily G { i, j } ; have := mem_cliqueFamily H { i, j } ; simp_all +decide ;

/-- A symmetric dissimilarity gives a proximity graph at scale `r`. -/
def proximityGraph (D : α → α → ℝ) (r : ℝ) : SimpleGraph α where
  Adj i j := i ≠ j ∧ D i j ≤ r ∧ D j i ≤ r
  symm := by rintro i j ⟨hij, hijr, hjir⟩; exact ⟨hij.symm, hjir, hijr⟩
  loopless := ⟨fun i h => h.1 rfl⟩

/-- The finite Vietoris–Rips complex of a dissimilarity on an arbitrary finite type. -/
def vrComplex (D : α → α → ℝ) (r : ℝ) : Finset (Finset α) :=
  Finset.univ.powerset.filter fun S => ∀ i ∈ S, ∀ j ∈ S, D i j ≤ r

/-- For symmetric data whose diagonal lies below the scale, Vietoris–Rips simplices are
exactly cliques in the proximity graph. -/
theorem vrComplex_eq_cliqueFamily (D : α → α → ℝ) (r : ℝ)
    (hsymm : ∀ i j, D i j = D j i) (hdiag : ∀ i, D i i ≤ r) :
    vrComplex D r = cliqueFamily (proximityGraph D r) := by
  ext S;
  constructor <;> intro hS;
  · simp_all +decide [ vrComplex, cliqueFamily, SimpleGraph.IsClique ];
    exact fun i hi j hj hij => ⟨ hij, hS i hi j hj, hS j hj i hi |> fun h => by simpa only [ hsymm ] using h ⟩;
  · simp_all +decide [ cliqueFamily ];
    exact Finset.mem_filter.mpr ⟨ Finset.mem_powerset.mpr ( Finset.subset_univ _ ), fun i hi j hj => if hij : i = j then hij ▸ hdiag i else hS hi hj hij |>.2.1 ⟩

/-- **Metric extremal characterization.** For symmetric data with controlled diagonal,
the Vietoris–Rips complex contains all `2 ^ |α|` simplices exactly when every pair of
points is within scale. -/
theorem card_vrComplex_eq_two_pow_iff (D : α → α → ℝ) (r : ℝ)
    (hsymm : ∀ i j, D i j = D j i) (hdiag : ∀ i, D i i ≤ r) :
    (vrComplex D r).card = 2 ^ Fintype.card α ↔ ∀ i j, D i j ≤ r := by
  convert card_cliqueFamily_eq_two_pow_iff ( proximityGraph D r ) using 1;
  · rw [ vrComplex_eq_cliqueFamily D r hsymm hdiag ];
  · constructor <;> intro h <;> simp_all +decide [ SimpleGraph.ext_iff, proximityGraph ];
    · ext i j; simp +decide ;
    · intro i j; by_cases hij : i = j <;> simp_all +decide [ funext_iff ] ;

/-- **Strict simplex growth at an edge birth.** If a pair of distinct points crosses
from outside scale `r` to inside scale `s`, then the Vietoris–Rips complex gains
strictly more simplices.  Thus the finite simplex-count filtration detects every edge
birth, not merely the final complete-graph threshold. -/
theorem card_vrComplex_strictMono_at_edge
    (D : α → α → ℝ) (r s : ℝ) (hrs : r ≤ s)
    (hsymm : ∀ i j, D i j = D j i)
    (hdiag_r : ∀ i, D i i ≤ r)
    (i j : α) (hij : i ≠ j) (hri : r < D i j) (his : D i j ≤ s) :
    (vrComplex D r).card < (vrComplex D s).card := by
  -- Apply `card_cliqueFamily_strictMono` to the proximity graphs at `r` and `s`.
  have h_strict : (cliqueFamily (proximityGraph D r)).card < (cliqueFamily (proximityGraph D s)).card := by
    apply card_cliqueFamily_strictMono;
    refine' lt_of_le_of_ne _ _;
    · exact fun i j hij => ⟨ hij.1, le_trans hij.2.1 hrs, le_trans hij.2.2 hrs ⟩;
    · intro h;
      replace h := congr_arg ( fun G => G.Adj i j ) h ; simp_all +decide [ proximityGraph ];
      linarith;
  rwa [ vrComplex_eq_cliqueFamily D r hsymm ( fun i => by linarith [ hdiag_r i ] ), vrComplex_eq_cliqueFamily D s hsymm ( fun i => by linarith [ hdiag_r i ] ) ]

end VRCliqueExtremalDeepening