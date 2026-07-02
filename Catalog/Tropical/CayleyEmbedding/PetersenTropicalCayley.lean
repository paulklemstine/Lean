/-
# Non-embeddability of the Petersen graph into tropical abelian Cayley graphs

This file lifts the classical metric obstruction to isometric embedding of the
**Petersen graph** into bipartite abelian Cayley graphs (see the catalog files
`Applications/CayleyStability/PetersenAbelianCayley.lean` and
`PetersenNonBipartite.lean`, whose Kneser-model construction and coloring-pullback
argument are reproduced here in self-contained form) to the **tropical** setting.

The genuinely new ingredient is that the bipartite host graphs are now produced
by a **tropical valuation** `v : A →+ ℤ` — a homomorphism from the abelian group
`A` into the value group `ℤ` of the min-plus (tropical) semiring
`MinPlusSemiring` from `Catalog/Tropical/IdempotentSemiring/Defs.lean`.  The
connection set of the Cayley graph is the *valuation level structure*
`{a | Odd (v a)}` — the elements whose tropical valuation is odd — and the parity
of the valuation is exactly the bipartite `ℤ/2`-certificate.

## Main results

* `colorable_of_isometric` : an isometric map pulls back a proper `n`-coloring of
  the host to a proper `n`-coloring of the source (metric obstruction, any `n`).
* `Petersen_not_colorable_two` : the Petersen graph is not `2`-colorable.
* `tropicalCayley_colorable_two` : the tropical Cayley graph with connection set
  `{a | Odd (v a)}` is bipartite, certified by the parity of the valuation.
* `petersen_no_isometric_into_tropicalCayley` : **main theorem** — the Petersen
  graph does not isometrically embed into any such tropical Cayley graph.
* `petersen_no_isometric_into_odd_lattice` : concrete instance on the integer
  lattice `ℤ^k` with the coordinate-sum valuation.

## Tropical-valuation bridge (uses the catalog's min-plus semiring)

* `tropVal` : a valuation viewed with values in `MinPlusSemiring`.
* `tropVal_add_eq_max`, `tropVal_add_self` : the tropical (min-plus) combination
  rules for the valuation, via `IdempotentOrdAddCommMonoid.add_eq_max` and the
  idempotency of tropical addition.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The recorded fact "Petersen is not a partial cube" is
a shadow of a purely metric/coloring principle that survives *any* change of the
distance-generating algebra.  Bold conjecture: replace the classical
`ℤ/2`-character certificate for bipartiteness by a TROPICAL valuation — a
homomorphism into the min-plus value group — and rule out an entire
valuation-defined family of Cayley hosts at once.

Experiment (Experimenter): (1) Reproduced the coloring-pullback obstruction
`colorable_of_isometric`; the metric hypothesis is used exactly once, to send a
`G`-edge (`dist = 1`) to an `H`-edge.  (2) Reproduced the Kneser `K(5,2)` model
and its odd pentagon, giving `¬ Colorable 2`.  (3) NEW: defined the connection
set as the valuation level structure `{a | Odd (v a)}`; symmetry is
`v (-a) = -(v a)` (odd is preserved by negation), looplessness is `v 0 = 0`
(even).  (4) NEW: the parity `a ↦ (v a : ℤ/2)` is an additive character equal to
`1` on every generator, so the tropical Cayley graph is bipartite; combined with
(1)+(2) this forbids the Petersen embedding.  (5) Concrete host: `ℤ^k` with the
coordinate-sum valuation, whose odd-valuation graph is the classical bipartite
integer lattice.

Analysis (Analyst): The obstruction is `n`-general (`colorable_of_isometric`);
the tropical content is confined to the bipartite certificate, where a single
`ℤ/2`-valued reduction of the valuation replaces the ad-hoc group character.
What the argument does NOT cover: Cayley hosts whose generators all have even
valuation are not necessarily bipartite, so the Petersen graph might embed there
— this boundary is recorded in FUTURE_DIRECTIONS.

Critique (Critic): No theorem is `True`/`rfl`/`native_decide`.  The metric
hypothesis is load-bearing (drop it and a triangle can be crushed into an edge,
breaking `colorable_of_isometric`).  The valuation is load-bearing: it defines
the connection set AND supplies the parity certificate; the min-plus bridge
lemmas genuinely invoke the catalog `IdempotentOrdAddCommMonoid` instance.

Synthesis (PI): "metric obstruction (any n) + tropical-valuation parity
certificate (n = 2)" cleanly isolates which tropical hosts are ruled out and
turns the even-valuation case into a sharp open conjecture.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Catalog.Tropical.IdempotentSemiring.Defs

open SimpleGraph

namespace TropicalPetersen

/-! ## §1. Metric obstruction (reproduced from the catalog Petersen files) -/

/-- **Metric obstruction (any number of colors).** An isometric map `f`
(satisfying `H.dist (f u) (f v) = G.dist u v`) pulls back a proper `n`-coloring
of the host `H` to a proper `n`-coloring of the source `G`.  The metric
hypothesis enters exactly once: to send a `G`-edge to an `H`-edge. -/
lemma colorable_of_isometric {V W : Type*} {G : SimpleGraph V} {H : SimpleGraph W}
    (f : V → W) (hf : ∀ u v, H.dist (f u) (f v) = G.dist u v) {n : ℕ}
    (hH : H.Colorable n) : G.Colorable n := by
  obtain ⟨c⟩ := hH
  refine ⟨Coloring.mk (fun v => c (f v)) ?_⟩
  intro u v huv
  have h1 : G.dist u v = 1 := dist_eq_one_iff_adj.mpr huv
  have h2 : H.Adj (f u) (f v) := dist_eq_one_iff_adj.mp (by rw [hf, h1])
  exact c.valid h2

/-- A graph that is **not** `n`-colorable admits no isometric embedding into an
`n`-colorable graph. -/
theorem no_isometric_into_colorable {V W : Type*} {G : SimpleGraph V}
    {H : SimpleGraph W} {n : ℕ} (hG : ¬ G.Colorable n) (hH : H.Colorable n)
    (f : V → W) : ¬ (∀ u v, H.dist (f u) (f v) = G.dist u v) :=
  fun hf => hG (colorable_of_isometric f hf hH)

/-! ## §2. The Petersen graph (Kneser model `K(5,2)`) and non-bipartiteness -/

/-- Vertices of the Petersen graph: the two-element subsets of `Fin 5`. -/
def PetersenV := {s : Finset (Fin 5) // s.card = 2}

instance : DecidableEq PetersenV := by unfold PetersenV; infer_instance
instance : Fintype PetersenV := by unfold PetersenV; infer_instance

/-- The **Petersen graph** as the Kneser graph `K(5,2)`. -/
def Petersen : SimpleGraph PetersenV :=
  SimpleGraph.fromRel (fun s t => Disjoint s.1 t.1)

instance : DecidableRel Petersen.Adj := fun a b => by
  unfold Petersen SimpleGraph.fromRel; infer_instance

def v01 : PetersenV := ⟨{0, 1}, by decide⟩
def v23 : PetersenV := ⟨{2, 3}, by decide⟩
def v40 : PetersenV := ⟨{4, 0}, by decide⟩
def v12 : PetersenV := ⟨{1, 2}, by decide⟩
def v34 : PetersenV := ⟨{3, 4}, by decide⟩

/-- An explicit odd closed walk of length `5` in the Petersen graph. -/
def petersenPentagon : Petersen.Walk v01 v01 :=
  .cons (show Petersen.Adj v01 v23 by decide)
    (.cons (show Petersen.Adj v23 v40 by decide)
      (.cons (show Petersen.Adj v40 v12 by decide)
        (.cons (show Petersen.Adj v12 v34 by decide)
          (.cons (show Petersen.Adj v34 v01 by decide) .nil))))

/-- **The Petersen graph is not bipartite.** -/
theorem Petersen_not_colorable_two : ¬ Petersen.Colorable 2 := by
  rw [two_colorable_iff_forall_loop_even]
  push_neg
  exact ⟨v01, petersenPentagon, by decide⟩

/-! ## §3. Cayley graphs of abelian groups -/

variable {A : Type*} [AddCommGroup A]

/-- The **Cayley graph** of an additive abelian group `A` with symmetric
connection set `S` (with `0 ∉ S`): `g` and `h` are adjacent iff `h - g ∈ S`. -/
def cayleyGraph (S : Set A) (hsymm : ∀ s ∈ S, -s ∈ S) (h0 : (0 : A) ∉ S) :
    SimpleGraph A where
  Adj g h := (h - g) ∈ S
  symm := fun g h hgh => by
    have : -(h - g) ∈ S := hsymm _ hgh
    simpa [neg_sub] using this
  loopless := ⟨fun g hg => h0 (by simpa using hg)⟩

/-! ## §4. The tropical valuation and its min-plus values -/

/-- A **tropical valuation** viewed with values in the catalog min-plus semiring
`MinPlusSemiring`.  Its underlying value is the integer `v a` regarded inside
`WithTop ℤ` (the value group of the min-plus semiring). -/
def tropVal (v : A →+ ℤ) (a : A) : MinPlusSemiring := ⟨(v a : WithTop ℤ)⟩

@[simp] lemma tropVal_val (v : A →+ ℤ) (a : A) :
    (tropVal v a).val = ((v a : ℤ) : WithTop ℤ) := rfl

/-- Tropical (min-plus) combination of two valuations, via the catalog
`IdempotentOrdAddCommMonoid.add_eq_max` on `MinPlusSemiring`. -/
lemma tropVal_add_eq_max (v : A →+ ℤ) (a b : A) :
    tropVal v a + tropVal v b = max (tropVal v a) (tropVal v b) :=
  IdempotentOrdAddCommMonoid.add_eq_max _ _

/-- Tropical addition is idempotent on a valuation value (catalog `add_idem`). -/
lemma tropVal_add_self (v : A →+ ℤ) (a : A) :
    tropVal v a + tropVal v a = tropVal v a :=
  IdempotentOrdAddCommMonoid.add_idem _

/-! ## §5. The tropical Cayley graph and its bipartiteness -/

/-- The **odd-valuation connection set**: the elements whose tropical valuation
is odd.  This is the valuation level structure that defines the tropical Cayley
host. -/
def oddValGen (v : A →+ ℤ) : Set A := {a | Odd (v a)}

lemma oddValGen_symm (v : A →+ ℤ) : ∀ s ∈ oddValGen v, -s ∈ oddValGen v := by
  intro s hs
  simp only [oddValGen, Set.mem_setOf_eq, map_neg] at hs ⊢
  exact hs.neg

lemma oddValGen_zero (v : A →+ ℤ) : (0 : A) ∉ oddValGen v := by
  simp only [oddValGen, Set.mem_setOf_eq, map_zero]
  decide

/-- The **tropical Cayley graph** of `A` associated to a valuation `v`: the
Cayley graph whose generators are the elements of odd valuation. -/
def tropicalCayley (v : A →+ ℤ) : SimpleGraph A :=
  cayleyGraph (oddValGen v) (oddValGen_symm v) (oddValGen_zero v)

/-- The reduction-of-the-valuation-mod-2 additive character `A →+ ℤ/2`. -/
def valParity (v : A →+ ℤ) : A →+ ZMod 2 :=
  (Int.castRingHom (ZMod 2)).toAddMonoidHom.comp v

@[simp] lemma valParity_apply (v : A →+ ℤ) (a : A) :
    valParity v a = ((v a : ℤ) : ZMod 2) := rfl

lemma valParity_of_odd (v : A →+ ℤ) {a : A} (ha : Odd (v a)) :
    valParity v a = 1 := by
  rw [valParity_apply]
  obtain ⟨k, hk⟩ := ha
  have hdvd : ((2 : ℤ) ∣ (v a - 1)) := ⟨k, by rw [hk]; ring⟩
  have h2 := (ZMod.intCast_zmod_eq_zero_iff_dvd (v a - 1) 2).mpr hdvd
  push_cast at h2 ⊢
  linear_combination h2

/-- **The tropical Cayley graph is bipartite**, certified by the parity of the
tropical valuation. -/
theorem tropicalCayley_colorable_two (v : A →+ ℤ) :
    (tropicalCayley v).Colorable 2 := by
  have hc : Fintype.card (ZMod 2) = 2 := by decide
  rw [tropicalCayley, ← hc]
  refine Coloring.colorable (Coloring.mk (fun g => valParity v g) ?_)
  intro g h hgh
  have hs : valParity v (h - g) = 1 := valParity_of_odd v hgh
  rw [map_sub] at hs
  intro hcontra
  simp only at hcontra
  rw [hcontra, sub_self] at hs
  exact absurd hs (by decide)

/-! ## §6. Main non-embeddability theorem -/

/-- **Main theorem.** The Petersen graph does not isometrically embed into any
tropical Cayley graph `tropicalCayley v` — a Cayley graph whose connection set is
the odd-valuation level structure of a tropical valuation `v : A →+ ℤ`. -/
theorem petersen_no_isometric_into_tropicalCayley (v : A →+ ℤ) (f : PetersenV → A) :
    ¬ (∀ u w, (tropicalCayley v).dist (f u) (f w) = Petersen.dist u w) :=
  no_isometric_into_colorable Petersen_not_colorable_two
    (tropicalCayley_colorable_two v) f

/-! ## §7. Concrete host: the integer lattice `ℤ^k` -/

/-- The coordinate-sum valuation on `ℤ^k`, a homomorphism into the value group of
the min-plus semiring. -/
def latticeVal (k : ℕ) : (Fin k → ℤ) →+ ℤ where
  toFun x := ∑ i, x i
  map_zero' := by simp
  map_add' x y := by simp [Finset.sum_add_distrib]

/-- **Concrete corollary.** The Petersen graph does not isometrically embed into
the integer lattice `ℤ^k` with the odd-coordinate-sum connection set (which
contains all standard basis vectors, of valuation `1`). -/
theorem petersen_no_isometric_into_odd_lattice (k : ℕ)
    (f : PetersenV → (Fin k → ℤ)) :
    ¬ (∀ u w, (tropicalCayley (latticeVal k)).dist (f u) (f w) = Petersen.dist u w) :=
  petersen_no_isometric_into_tropicalCayley (latticeVal k) f

end TropicalPetersen