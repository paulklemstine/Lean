import Mathlib
import Logic.PosetTheory.ProofSystemCollapse
import Bridges.PigeonholeInjectionBridge.PigeonholeInjectionBridge

/-!
# Classical witnesses embedded in quantum proof models

A quantum proof is represented extensionally by a finite complex amplitude vector,
together with its classical conclusion and a resource size.  This level of abstraction
isolates two unconditional facts from unresolved proof-complexity claims.  First, every
classical proof embeds as a computational-basis state with exactly the same declared
size.  Second, any verified decoder from quantum witnesses back to classical proofs
turns a putative quantum size advantage into a precise lower bound on decoder overhead.

The development also connects the abstract simulation result to the finite pigeonhole
principle: when more proof labels than witness labels must be encoded, two proof labels
necessarily share a witness label, so lossless decoding is impossible.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Classical proof systems should embed isometrically into an
amplitude-vector quantum witness model, while any converse polynomial simulation must
be supplied by a genuine extraction theorem. Ranked by expected impact, the falsifiable
conjectures were: (1) a natural proof system has a super-polynomial quantum separation;
(2) every efficient quantum verifier has a uniform polynomial classical extractor;
(3) bounded-error encodings evade exact pigeonhole obstruction with a sharp
information-theoretic tradeoff; (4) restricted stabilizer witnesses always admit
polynomial extraction; (5) extractor degree sharply controls the root of classical
lower bounds; and (6) polynomial simulation remains closed under all verifier-preserving
compositions. The first three are deliberately grand-challenge claims.

Experiment (Experimenter): Basis-state encoding gives an unconditional size-preserving
forward translation. An abstract decoder was then composed with this encoding, and
finite witness alphabets were tested against injectivity using the catalog's pigeonhole
theorem.

Analysis (Analyst): The forward inclusion is structural and unconditional; the reverse
polynomial bound is exactly the unresolved content and cannot be inferred from QMA's
definition. Exponential pigeonhole compression is incompatible with lossless decoding
in a finite model unless additional verification structure, interaction, or error is
introduced.

Critique (Critic): No claim is made that amplitude vectors capture efficient quantum
verification, uniform circuit families, bounded error, or physical qubit count. The
results therefore refute neither classical lower bounds nor establish a QMA separation.
They identify the exact hypotheses required for such claims and prevent a dimension
count from being mislabeled as a proof-size separation.

Synthesis (Principal Investigator): Classical-to-quantum simulation has unit overhead
in the witness model; decoder composition yields polynomial classical simulation when
a polynomial extractor exists; and pigeonhole counting gives a sharp obstruction to
lossless finite compression.
-- !-- Lab Notes -- !--
-/

namespace QuantumProofsClassicalTheorems

open ProofSystemCollapse

/-- A finite-dimensional pure quantum witness, recorded by its amplitudes. -/
structure QuantumWitness (F : Type*) where
  /-- Dimension of the ambient Hilbert space. -/
  dim : ℕ
  /-- Amplitude vector in the computational basis. -/
  amplitude : Fin dim → ℂ
  /-- Classical statement certified by the witness. -/
  conclusion : F
  /-- Declared proof resource, separated from Hilbert-space dimension. -/
  cost : ℕ

/-- The abstract quantum proof system obtained from finite amplitude vectors. -/
def quantumSystem (F : Type*) : ProofSys F where
  Proof := QuantumWitness F
  concl := QuantumWitness.conclusion
  size := QuantumWitness.cost

/-- Embed a classical proof as the unique basis vector in a one-dimensional space. -/
def basisEncode {F : Type*} (C : ProofSys F) (p : C.Proof) : QuantumWitness F where
  dim := 1
  amplitude := fun _ => 1
  conclusion := C.concl p
  cost := C.size p

/-- Every classical proof system polynomially simulates into the amplitude-vector
quantum model with unit overhead.  The translation preserves both conclusions and
proof sizes exactly. -/
theorem classical_embeds_quantum {F : Type*} (C : ProofSys F) :
    PSimulates (quantumSystem F) C := by
  refine ⟨basisEncode C, 1, 1, ?_, ?_⟩
  · intro p
    rfl
  · intro p
    change C.size p ≤ 1 * (C.size p + 1) ^ 1
    simp

/-- A verified extractor translates every quantum witness into a classical proof,
preserving its conclusion and obeying a polynomial size bound. -/
structure PolynomialExtractor {F : Type*} (C : ProofSys F) where
  /-- Extracted classical proof. -/
  decode : QuantumWitness F → C.Proof
  /-- Multiplicative polynomial constant. -/
  constant : ℕ
  /-- Polynomial degree. -/
  degree : ℕ
  /-- Extraction preserves the certified statement. -/
  conclusion_eq : ∀ q, C.concl (decode q) = q.conclusion
  /-- Extraction has polynomial overhead in the declared quantum cost. -/
  size_bound : ∀ q, C.size (decode q) ≤ constant * (q.cost + 1) ^ degree

/-- A polynomial extractor is precisely sufficient to turn the quantum witness model
back into a polynomial simulation by the classical system. -/
theorem extractor_gives_reverse_simulation {F : Type*} (C : ProofSys F)
    (E : PolynomialExtractor C) : PSimulates C (quantumSystem F) := by
  refine ⟨E.decode, E.constant, E.degree, ?_, ?_⟩
  · intro q
    exact E.conclusion_eq q
  · intro q
    exact E.size_bound q

/-- With a polynomial extractor, classical and quantum proof systems mutually
polynomially simulate one another. -/
theorem polynomial_equivalence_from_extractor {F : Type*} (C : ProofSys F)
    (E : PolynomialExtractor C) :
    PSimulates (quantumSystem F) C ∧ PSimulates C (quantumSystem F) := by
  constructor
  · exact classical_embeds_quantum C
  · exact extractor_gives_reverse_simulation C E

/-- The two translations compose to a polynomial self-simulation of the classical
system. This records the structural hierarchy behind any claimed polynomial collapse. -/
theorem extracted_basis_roundtrip_psimulates {F : Type*} (C : ProofSys F)
    (E : PolynomialExtractor C) : PSimulates C C := by
  apply psim_trans (extractor_gives_reverse_simulation C E)
  exact classical_embeds_quantum C

/-- If a classical proof has a lower bound `L`, then every conclusion-preserving
extraction of a quantum witness proving the same formula must incur at least `L` in
classical proof size. -/
theorem extraction_overhead_lower_bound {F : Type*} (C : ProofSys F)
    (E : PolynomialExtractor C) (f : F) (L : ℕ)
    (hLower : ∀ p : C.Proof, C.concl p = f → L ≤ C.size p)
    (q : QuantumWitness F) (hq : q.conclusion = f) :
    L ≤ E.constant * (q.cost + 1) ^ E.degree := by
  have hconcl : C.concl (E.decode q) = f := by
    rw [E.conclusion_eq q, hq]
  exact le_trans (hLower (E.decode q) hconcl) (E.size_bound q)

/-- Quantitative corollary: a polynomial extractor of positive degree forces a lower
bound on quantum cost whenever the classical lower bound exceeds its polynomial image. -/
theorem quantum_cost_lower_bound_of_extractor {F : Type*} (C : ProofSys F)
    (E : PolynomialExtractor C) (f : F) (L n : ℕ)
    (hLower : ∀ p : C.Proof, C.concl p = f → L ≤ C.size p)
    (hGap : E.constant * (n + 1) ^ E.degree < L)
    (q : QuantumWitness F) (hq : q.conclusion = f) : n < q.cost := by
  by_contra hnot
  have hcost : q.cost ≤ n := by omega
  have hpow : (q.cost + 1) ^ E.degree ≤ (n + 1) ^ E.degree :=
    Nat.pow_le_pow_left (by omega) E.degree
  have hupper : E.constant * (q.cost + 1) ^ E.degree < L :=
    lt_of_le_of_lt (Nat.mul_le_mul_left E.constant hpow) hGap
  have hlower := extraction_overhead_lower_bound C E f L hLower q hq
  omega

/-- Finite lossless proof compression cannot map a larger proof-label type into a
smaller witness-label type.  This imports the catalog pigeonhole theorem as an
information-theoretic obstruction to naive exponential compression. -/
theorem no_lossless_quantum_label_compression {ClassicalLabel QuantumLabel : Type*}
    [Fintype ClassicalLabel] [Fintype QuantumLabel]
    (hcard : Fintype.card QuantumLabel < Fintype.card ClassicalLabel)
    (encode : ClassicalLabel → QuantumLabel) (decode : QuantumLabel → ClassicalLabel) :
    ¬ (∀ p, decode (encode p) = p) := by
  intro hroundtrip
  have hinj : Function.Injective encode := by
    intro p q hpq
    calc
      p = decode (encode p) := (hroundtrip p).symm
      _ = decode (encode q) := congrArg decode hpq
      _ = q := hroundtrip q
  exact PigeonholeInjectionBridge.no_injection_of_card_lt hcard encode hinj

/-- More directly, every encoding into a smaller finite witness alphabet identifies two
distinct classical proof labels. -/
theorem quantum_label_collision {ClassicalLabel QuantumLabel : Type*}
    [Fintype ClassicalLabel] [Fintype QuantumLabel]
    (hcard : Fintype.card QuantumLabel < Fintype.card ClassicalLabel)
    (encode : ClassicalLabel → QuantumLabel) :
    ∃ p q, p ≠ q ∧ encode p = encode q := by
  exact PigeonholeInjectionBridge.pigeonhole encode hcard

end QuantumProofsClassicalTheorems