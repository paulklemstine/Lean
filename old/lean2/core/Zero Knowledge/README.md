# Zero-Knowledge Proofs: Proving You Know Secrets Without Revealing Them

## Overview

This project provides a comprehensive treatment of **zero-knowledge proofs** (ZKPs) — the
mathematical technology for proving knowledge of secret information without revealing it.

## Contents

### 📐 Formal Lean 4 Proofs (`Basic.lean`)
Machine-verified proofs of core ZKP properties:
- **Schnorr Completeness:** Honest provers always convince honest verifiers
- **Schnorr Extraction (Soundness):** Two accepting transcripts reveal the secret
- **Schnorr Simulator Validity:** Simulated transcripts are indistinguishable (zero-knowledge)
- **Cave Soundness Bounds:** After 20 rounds, fakers have <1-in-a-million chance
- **Commitment Scheme Binding:** Binding commitments prevent equivocation
- **Sigma Protocol Framework:** Generic completeness for any sigma protocol

### 🐍 Python Demos (`demos/`)
Interactive visualizations:
1. **Ali Baba Cave** — Intuitive ZKP analogy with Monte Carlo simulation
2. **Schnorr Protocol** — Step-by-step protocol execution with distribution comparison
3. **Graph 3-Coloring** — The universal ZKP (any NP problem reduces to this)
4. **Selling Secrets** — Complete protocol for monetizing mathematical knowledge

Run: `python3 demos/demo1_ali_baba_cave.py` (etc.)

### 📄 Papers (`papers/`)
- **Research Paper** — Full technical treatment with formal definitions and proofs
- **Scientific American Article** — Accessible explanation for general audiences

### 📝 Notes (`notes/`)
- **Oracle Council Notes** — Research methodology, hypotheses, experiments, and iterations

## The Core Idea

You can prove you know a mathematical secret (a factorization, a polynomial root,
a discrete logarithm, a proof of a theorem) without revealing any information about
the secret itself. The key properties are:

| Property | Meaning |
|----------|---------|
| **Completeness** | If you know the secret, you can always convince the verifier |
| **Soundness** | If you don't know the secret, you can't fake it |
| **Zero-Knowledge** | The verifier learns nothing about the secret |

## Your Use Case: Selling Secrets

The protocol for selling mathematical secrets:
1. **Advertise:** Publish a commitment to your secret
2. **ZK-Prove:** Convince the buyer you know the secret (without revealing it)
3. **Escrow:** Buyer deposits payment
4. **Reveal:** Open the commitment, payment is released

See `demos/demo4_sell_secrets_protocol.py` and `papers/research_paper.md` §5.
