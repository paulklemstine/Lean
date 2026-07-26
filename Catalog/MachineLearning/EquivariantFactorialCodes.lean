import Mathlib.GroupTheory.Perm.Fin
import Novelty.FactorialCRTObstruction

/-!
# Equivariant factorial codes

A factorial code of length `k` chooses its digit at position `i` from
`Fin (i + 1)`.  The recursive presentation makes the mixed-radix structure
explicit.  The central equivalence identifies these codes with permutations of
`Fin k`; transporting left multiplication then equips the code space with a
free and transitive symmetric-group action.

The final result records a sharp boundary: this set-theoretic and equivariant
classification does not turn the digits into independent Chinese-remainder
coordinates.  At length four, the corresponding residue product is not even
additively equivalent to `ZMod (4!)`.
-/

namespace EquivariantFactorialCodes

/-- Mixed-radix factorial codes: digit `i` lies in `Fin (i + 1)`. -/
abbrev FactorialCode (k : Nat) := ∀ i : Fin k, Fin (i.val + 1)

/-- Splitting off the highest-radix digit is an equivalence. -/
def codeSuccEquiv (k : Nat) :
    FactorialCode (k + 1) ≃ Fin (k + 1) × FactorialCode k :=
  (Fin.snocEquiv (fun i : Fin (k + 1) => Fin (i.val + 1))).symm

/-- The recursive Lehmer classification, aligned with permutation
`decomposeFin` at every stage. -/
def permCodeEquiv : (k : Nat) → Equiv.Perm (Fin k) ≃ FactorialCode k
  | 0 => Equiv.ofUnique _ _
  | k + 1 =>
      Equiv.Perm.decomposeFin |>.trans
        ((Equiv.prodCongr (Equiv.refl _) (permCodeEquiv k)).trans
          (codeSuccEquiv k).symm)

/-- Encoding a permutation as its factorial code. -/
def encode {k : Nat} : Equiv.Perm (Fin k) → FactorialCode k := permCodeEquiv k

/-- Decoding a factorial code to the classified permutation. -/
def decode {k : Nat} : FactorialCode k → Equiv.Perm (Fin k) := (permCodeEquiv k).symm

@[simp] theorem decode_encode {k : Nat} (σ : Equiv.Perm (Fin k)) :
    decode (encode σ) = σ := by
  exact (permCodeEquiv k).symm_apply_apply σ

@[simp] theorem encode_decode {k : Nat} (c : FactorialCode k) :
    encode (decode c) = c := by
  exact (permCodeEquiv k).apply_symm_apply c

/-- Every length-`k` factorial-code space has exactly `k!` elements. -/
theorem card_factorialCode (k : Nat) :
    Fintype.card (FactorialCode k) = Nat.factorial k := by
  rw [← Fintype.card_congr (permCodeEquiv k)]
  simpa using (Fintype.card_perm (α := Fin k))

/-- Left multiplication of permutations transported to factorial codes. -/
def codeAction {k : Nat} (σ : Equiv.Perm (Fin k)) (c : FactorialCode k) :
    FactorialCode k := encode (σ * decode c)

/-- Decoding is equivariant for the transported action and left multiplication. -/
@[simp] theorem decode_codeAction {k : Nat} (σ : Equiv.Perm (Fin k))
    (c : FactorialCode k) :
    decode (codeAction σ c) = σ * decode c := by
  exact decode_encode _

@[simp] theorem codeAction_one {k : Nat} (c : FactorialCode k) :
    codeAction 1 c = c := by
  convert encode_decode c

/-- Encoding is equivariant for left multiplication. -/
theorem encode_mul_equivariant {k : Nat} (σ τ : Equiv.Perm (Fin k)) :
    encode (σ * τ) = codeAction σ (encode τ) := by
  rw [codeAction, decode_encode]

/-- Transported multiplication is a genuine left action. -/
theorem codeAction_mul {k : Nat} (σ τ : Equiv.Perm (Fin k))
    (c : FactorialCode k) :
    codeAction (σ * τ) c = codeAction σ (codeAction τ c) := by
  unfold codeAction
  rw [decode_encode, mul_assoc]

/-- The transported symmetric-group action is free. -/
theorem codeAction_free {k : Nat} (σ : Equiv.Perm (Fin k))
    (c : FactorialCode k) (h : codeAction σ c = c) : σ = 1 := by
  apply_fun decode at h
  simp only [codeAction, decode_encode] at h
  exact mul_right_cancel (h.trans (one_mul (decode c)).symm)

/-- The transported symmetric-group action is transitive. -/
theorem codeAction_transitive {k : Nat} (c d : FactorialCode k) :
    ∃ σ : Equiv.Perm (Fin k), codeAction σ c = d := by
  use decode d * (decode c)⁻¹
  simp [codeAction, mul_assoc]

/-- Factorial codes form a symmetric-group torsor: the transporter between any
ordered pair of codes exists and is unique. -/
theorem existsUnique_codeTransport {k : Nat} (c d : FactorialCode k) :
    ∃! σ : Equiv.Perm (Fin k), codeAction σ c = d := by
  refine ⟨decode d * (decode c)⁻¹, ?_, ?_⟩
  · simp [codeAction, mul_assoc]
  · intro σ hσ
    apply_fun decode at hσ
    simp only [codeAction, decode_encode] at hσ
    apply mul_right_cancel (b := decode c)
    simp [hσ]

/-- The equivariant classification and the CRT obstruction coexist: factorial
codes classify permutations at length four, but the radix residue rings do not
form additive coordinates for `ZMod (4!)`. -/
theorem lengthFour_classification_with_CRT_boundary :
    Nonempty (Equiv.Perm (Fin 4) ≃ FactorialCode 4) ∧
      ¬ Nonempty
        (ZMod (Nat.factorial 4) ≃+
          FactorialCRTObstruction.FactorialResidues4) := by
  refine ⟨⟨permCodeEquiv 4⟩, ?_⟩
  exact FactorialCRTObstruction.no_factorial_four_add_equiv

-- !-- Lab Notes -- !--
/-
Hypothesis: The selected target is a cross-domain bridge between mixed-radix
combinatorics, symmetric-group actions, and additive arithmetic.  The ranked
claims were: (1) codes form a symmetric-group torsor; (2) recursive encoding is
an equivalence at every length; (3) the code count is factorial; (4) the action
is free; (5) it is transitive; (6) length four separates equivariant coordinates
from CRT coordinates.  The recursive digit split should match the standard
decomposition of a permutation by the image of its first point.

Experiment: The recursive equivalence was used to transport left multiplication
from permutations to codes.  Freeness, transitivity, and uniqueness of the
transporter were then tested as increasingly stringent consequences.

Analysis: The classification survives for every length and gives the exact
factorial cardinality.  The decisive structural pattern is not merely an
enumeration: each code space is a torsor for the symmetric group.

Critique: Cardinality alone could have produced an arbitrary equivalence, so the
proof instead follows the recursive permutation decomposition.  The imported
length-four obstruction rules out the tempting but false strengthening to
independent residue-ring coordinates.

Synthesis: Factorial mixed-radix coordinates are naturally equivariant
coordinates for permutations, while repeated prime factors prevent a general
Chinese-remainder interpretation.
-/
-- !-- Lab Notes -- !--

end EquivariantFactorialCodes