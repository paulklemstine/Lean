/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Certified evidence: how far kernel computation reaches, and where it stops

Index module for the `CertifiedEvidence` development.

* `CertifiedEvidence.Core` — a verified reflection kernel for bounded universal
  statements: soundness *and* completeness, the composition law for chunked
  certification, list/array implementations, counterexample extraction.
* `CertifiedEvidence.Insufficiency` — no finite bound is a proof: truncation,
  the diagonal argument, and the continuum-sized version space that survives
  any finite amount of evidence.
* `CertifiedEvidence.Sufficiency` — descent certificates: sound, and complete
  for universal statements; periodic and shift certificates as instances; two
  universal theorems proved from tiny kernel windows.
* `CertifiedEvidence.Collatz` — a sound fuelled Collatz checker, the mod-4
  sieve, and kernel certificates for `[1,20]`, `[1,1000]`, `[1,4000]`.
* `CertifiedEvidence.ScaleSieve` — the mod-4 sieve as the scale-2 member of a
  family whose workload density tends to zero, together with the proof that the
  scale-2 sieve is exactly optimal.
* `CertifiedEvidence.FastCertificates` — balanced reflection and the drop-below
  checker; kernel-verified bound `[1,131072]`.
* `CertifiedEvidence.LearningBoundary` — the dichotomy: continuum version space
  for the unrestricted class, exact identification for a periodic class.
-/

import MachineLearning.CertifiedEvidence.Core
import MachineLearning.CertifiedEvidence.Insufficiency
import MachineLearning.CertifiedEvidence.Sufficiency
import MachineLearning.CertifiedEvidence.Collatz
import MachineLearning.CertifiedEvidence.ScaleSieve
import MachineLearning.CertifiedEvidence.FastCertificates
import MachineLearning.CertifiedEvidence.LearningBoundary