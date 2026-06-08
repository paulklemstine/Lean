/-
# L-Function Census: Core Definitions

This module defines the combinatorial structures underlying a census
of L-functions in the Selberg class.
-/
import Mathlib

open Finset BigOperators

/-- A spectral parameter in the gamma factor of a Selberg-class L-function. -/
structure SpectralParam where
  shift : ℤ
  parity : Fin 2
  deriving DecidableEq, Repr

namespace SpectralParam

def absShift (p : SpectralParam) : ℕ := p.shift.natAbs

def zero : SpectralParam := ⟨0, 0⟩

end SpectralParam

/-- The invariant data of a Selberg-class L-function:
    degree, conductor, and spectral parameters. -/
structure SelbergDatum where
  degree : ℕ
  conductor : ℕ+
  spectralParams : List SpectralParam
  params_length : spectralParams.length = degree

namespace SelbergDatum

def trivialDatum : SelbergDatum where
  degree := 0
  conductor := ⟨1, Nat.one_pos⟩
  spectralParams := []
  params_length := rfl

/-- Product of two Selberg data (Rankin-Selberg convolution). -/
def prod (d₁ d₂ : SelbergDatum) : SelbergDatum where
  degree := d₁.degree + d₂.degree
  conductor := ⟨d₁.conductor.val * d₂.conductor.val,
    Nat.mul_pos d₁.conductor.pos d₂.conductor.pos⟩
  spectralParams := d₁.spectralParams ++ d₂.spectralParams
  params_length := by simp [List.length_append, d₁.params_length, d₂.params_length]

/-- The spectral complexity: sum of absolute shifts. -/
def spectralComplexity (d : SelbergDatum) : ℕ :=
  (d.spectralParams.map SpectralParam.absShift).sum

/-- The spectral weight: maximum absolute shift. -/
def spectralWeight (d : SelbergDatum) : ℕ :=
  (d.spectralParams.map SpectralParam.absShift).foldl max 0

/-- A datum is primitive if it has positive degree and cannot be
    nontrivially decomposed. -/
def isPrimitive (d : SelbergDatum) : Prop :=
  d.degree ≥ 1 ∧ ∀ d₁ d₂ : SelbergDatum,
    d₁.degree + d₂.degree = d.degree →
    d₁.conductor.val * d₂.conductor.val = d.conductor.val →
    d₁.degree = 0 ∨ d₂.degree = 0

/-- The factorization preorder: d₁ ≤ d₂ if d₁.degree ≤ d₂.degree
    and d₁.conductor | d₂.conductor. -/
def factLE (d₁ d₂ : SelbergDatum) : Prop :=
  d₁.degree ≤ d₂.degree ∧ d₁.conductor.val ∣ d₂.conductor.val

/-- The strict factorization order. -/
def factLT (d₁ d₂ : SelbergDatum) : Prop :=
  factLE d₁ d₂ ∧ ¬ factLE d₂ d₁

end SelbergDatum

/-- The conductor counting function N_d(Q, B):
    Q choices of conductor × (2·(2B+1))^d choices of spectral params. -/
def conductorCount (d Q B : ℕ) : ℕ :=
  Q * ((2 * (2 * B + 1)) ^ d)

/-- A spectral type abstracts a SelbergDatum to degree + sorted
    multiset of absolute shifts. -/
structure SpectralType where
  degree : ℕ
  profile : List ℕ
  profile_length : profile.length = degree
  profile_sorted : profile.Pairwise (· ≤ ·)

namespace SpectralType

def unit : SpectralType where
  degree := 0
  profile := []
  profile_length := rfl
  profile_sorted := List.Pairwise.nil

noncomputable def prod (t₁ t₂ : SpectralType) : SpectralType where
  degree := t₁.degree + t₂.degree
  profile := (t₁.profile ++ t₂.profile).mergeSort (· ≤ ·)
  profile_length := by
    simp [List.length_mergeSort, List.length_append,
          t₁.profile_length, t₂.profile_length]
  profile_sorted := by
    have htrans : ∀ (a b c : ℕ), (decide (a ≤ b)) = true → (decide (b ≤ c)) = true → (decide (a ≤ c)) = true := by
      intro a b c h1 h2; simp [decide_eq_true_eq] at *; omega
    have htotal : ∀ (a b : ℕ), ((decide (a ≤ b)) || (decide (b ≤ a))) = true := by
      intro a b; simp [decide_eq_true_eq, Bool.or_eq_true]; omega
    have h := List.pairwise_mergeSort htrans htotal (t₁.profile ++ t₂.profile)
    simp [decide_eq_true_eq] at h
    exact h

def complexity (t : SpectralType) : ℕ := t.profile.sum

def entropy (t : SpectralType) : ℕ := t.profile.dedup.length

end SpectralType

/-- The degree-conductor pair, a simplified invariant. -/
structure DegreeConductor where
  degree : ℕ
  conductor : ℕ+
  deriving DecidableEq

namespace DegreeConductor

instance : LE DegreeConductor where
  le d₁ d₂ := d₁.degree ≤ d₂.degree ∧ d₁.conductor.val ∣ d₂.conductor.val

instance : LT DegreeConductor where
  lt d₁ d₂ := d₁ ≤ d₂ ∧ ¬ (d₂ ≤ d₁)

def unit : DegreeConductor := ⟨0, ⟨1, Nat.one_pos⟩⟩

def prod (d₁ d₂ : DegreeConductor) : DegreeConductor where
  degree := d₁.degree + d₂.degree
  conductor := ⟨d₁.conductor.val * d₂.conductor.val,
    Nat.mul_pos d₁.conductor.pos d₂.conductor.pos⟩

def size (d : DegreeConductor) : ℕ := d.degree + d.conductor.val

end DegreeConductor