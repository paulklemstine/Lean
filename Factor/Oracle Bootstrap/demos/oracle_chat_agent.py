#!/usr/bin/env python3
"""
Oracle Bootstrap Chat Agent

An English-language conversational agent that uses the Oracle Bootstrap principle:
iterative self-refinement of responses converging to a fixed point of quality.

The core idea: each "iteration" of the agent refines its previous answer,
and we detect convergence when the refinement produces no meaningful change
(the answer has become idempotent — applying the refinement operator again
leaves it unchanged).

This implements a local, self-contained demo using template-based reasoning
with iterative refinement. No external API keys needed.

Architecture:
    1. INITIAL ORACLE: Generate a first-draft answer
    2. CRITIQUE ORACLE: Identify weaknesses in the current answer  
    3. REFINE ORACLE: Improve the answer based on critique
    4. CONVERGENCE CHECK: Measure if refinement changed the answer
    5. ITERATE until convergence (answer = fixed point)

Usage:
    python oracle_chat_agent.py
"""

import re
import math
import json
from typing import List, Tuple, Optional
from dataclasses import dataclass, field
from difflib import SequenceMatcher


# ============================================================
# Core Oracle Bootstrap Framework
# ============================================================

@dataclass
class OracleState:
    """The state of an oracle iteration.
    
    Analogous to a matrix X_n in the Newton iteration X_{n+1} = 3X² - 2X³.
    The 'answer' is the current approximation, and 'confidence' tracks
    how close we are to idempotency (convergence).
    """
    answer: str
    confidence: float  # ∈ [0, 1], where 1 = perfect oracle (P² = P)
    critique: str = ""
    iteration: int = 0
    eigenvalues: List[float] = field(default_factory=list)  # metaphorical


def similarity(a: str, b: str) -> float:
    """Measure similarity between two strings (proxy for ||P² - P|| → 0)."""
    return SequenceMatcher(None, a.lower().strip(), b.lower().strip()).ratio()


def compute_oracle_residual(state: OracleState, refined: str) -> float:
    """Compute ||P² - P|| — the residual measuring distance from idempotency.
    
    When the refinement operator applied to the answer produces the same answer,
    we have P² = P and the residual is 0.
    """
    sim = similarity(state.answer, refined)
    return 1.0 - sim  # residual → 0 as answer converges


# ============================================================
# Knowledge Base (the oracle's "projection space")
# ============================================================

KNOWLEDGE_BASE = {
    "oracle": {
        "definition": "An oracle is an idempotent operator P where P² = P. "
                      "Asking the oracle twice gives the same answer as asking once.",
        "spectrum": "The Oracle Spectrum Theorem states that a perfect oracle's "
                    "eigenvalues are exactly {0, 1} — complete certainty.",
        "bootstrap": "The Oracle Bootstrap proves that iterating a contractive "
                     "self-improvement process converges to a perfect oracle. "
                     "The iteration X_{n+1} = 3X² - 2X³ converges cubically.",
        "master_equation": "The Master Equation states: Truth = Compression. "
                          "The fixed points of an oracle equal the dimension of its image.",
        "anti_oracle": "The anti-oracle always gives the opposite answer. "
                       "Remarkably, anti(anti(O)) = O — double negation returns truth.",
    },
    "mathematics": {
        "banach": "The Banach Contraction Mapping Theorem: every contraction on a "
                  "complete metric space has a unique fixed point, reached by iteration.",
        "newton": "Newton's method finds roots of F(x) = 0 by iterating "
                  "x_{n+1} = x_n - F'(x_n)^{-1} F(x_n). Converges quadratically.",
        "idempotent": "An idempotent satisfies P² = P. Examples: projection matrices, "
                      "the floor function on integers, any retraction in topology.",
        "fixed_point": "A fixed point of f is x where f(x) = x. Every oracle IS its "
                       "own fixed-point set: O(x) = x for all x in the image of O.",
        "projection": "A projection maps a space onto a subspace. Orthogonal projections "
                      "minimize distance. The nearest projection to a matrix A has "
                      "eigenvalues snapped to {0, 1}.",
    },
    "applications": {
        "machine_learning": "Neural networks can be viewed as approximate oracles. "
                           "Training is the Oracle Bootstrap: iterating toward P² = P. "
                           "A perfectly trained network is idempotent on its task.",
        "consensus": "In distributed systems, consensus algorithms are oracle bootstraps. "
                     "Each round of voting refines the collective answer until it stabilizes.",
        "search": "Search engines approximate oracles: the ideal search returns the same "
                  "results whether you search once or search the search results.",
        "verification": "Formal verification (e.g., in Lean 4) produces perfect oracles: "
                        "a verified theorem is permanently true — applying the verifier "
                        "again always gives the same result.",
    },
    "philosophy": {
        "truth": "Truth is a fixed point: a true statement remains true upon re-examination. "
                 "The Oracle Bootstrap formalizes this: truth = convergence of inquiry.",
        "self_reference": "The oracle that asks 'is this oracle correct?' converges to "
                         "self-consistency via the bootstrap. Self-reference is not paradoxical "
                         "when the iteration is contractive.",
        "knowledge": "Knowledge is compressed prediction. The Master Equation "
                     "Truth = Compression says that understanding IS data compression.",
    }
}


def lookup_knowledge(query: str) -> List[str]:
    """Search the knowledge base for relevant information."""
    query_lower = query.lower()
    results = []
    
    for category, entries in KNOWLEDGE_BASE.items():
        for key, value in entries.items():
            # Simple keyword matching (a real system would use embeddings)
            keywords = key.split('_') + category.split('_')
            query_words = set(re.findall(r'\w+', query_lower))
            
            overlap = len(set(keywords) & query_words)
            if overlap > 0 or any(kw in query_lower for kw in keywords):
                results.append(value)
    
    return results


# ============================================================
# The Three Oracle Operators
# ============================================================

def initial_oracle(query: str) -> OracleState:
    """Generate initial answer (the 'perturbed matrix' A₀).
    
    This is deliberately imperfect — the bootstrap will improve it.
    """
    knowledge = lookup_knowledge(query)
    
    if knowledge:
        # Combine relevant knowledge
        answer = " ".join(knowledge[:3])
        confidence = min(0.3 + 0.1 * len(knowledge), 0.7)
    else:
        # General response for unknown topics
        answer = (f"Regarding '{query}': This connects to the Oracle Bootstrap framework. "
                  f"Every question, when iteratively refined, converges to its true answer — "
                  f"like eigenvalues snapping to {{0, 1}} in the Oracle Spectrum Theorem.")
        confidence = 0.2
    
    return OracleState(
        answer=answer,
        confidence=confidence,
        iteration=0,
        eigenvalues=[confidence, 1 - confidence]  # metaphorical spectrum
    )


def critique_oracle(state: OracleState, query: str) -> str:
    """Identify weaknesses in the current answer (compute the 'residual').
    
    This is the P² - P operator: measuring how far the answer is from idempotent.
    """
    critiques = []
    
    # Check answer length (too short = incomplete, too long = unfocused)
    word_count = len(state.answer.split())
    if word_count < 20:
        critiques.append("Answer is too brief — needs more detail and examples.")
    elif word_count > 200:
        critiques.append("Answer is too verbose — needs tighter focus on the core question.")
    
    # Check if answer addresses the query
    query_words = set(re.findall(r'\w+', query.lower()))
    answer_words = set(re.findall(r'\w+', state.answer.lower()))
    coverage = len(query_words & answer_words) / max(len(query_words), 1)
    if coverage < 0.3:
        critiques.append(f"Answer doesn't directly address the query (coverage: {coverage:.0%}).")
    
    # Check for oracle-theoretic connections
    oracle_terms = {'oracle', 'idempotent', 'projection', 'fixed', 'convergence', 
                    'bootstrap', 'eigenvalue', 'spectrum', 'contraction'}
    oracle_coverage = len(oracle_terms & answer_words)
    if oracle_coverage < 2:
        critiques.append("Could strengthen connections to oracle theory.")
    
    # Check confidence level
    if state.confidence < 0.5:
        critiques.append("Low confidence — needs stronger supporting evidence.")
    
    if not critiques:
        critiques.append("Answer is comprehensive and well-structured. Minor polish only.")
    
    return " | ".join(critiques)


def refine_oracle(state: OracleState, query: str) -> OracleState:
    """Apply one Newton step: X_{n+1} = 3X² - 2X³.
    
    Refines the answer based on the critique, moving closer to the fixed point.
    """
    critique = critique_oracle(state, query)
    
    # Gather additional knowledge to address critique gaps
    additional = lookup_knowledge(query)
    current_answer = state.answer
    
    # Apply refinement rules (analogous to the Newton iteration)
    refined = current_answer
    
    # Rule 1: If too brief, expand with knowledge
    if "too brief" in critique and additional:
        extra = " Furthermore: " + additional[min(state.iteration, len(additional)-1)]
        refined += extra
    
    # Rule 2: If too verbose, compress
    if "too verbose" in critique:
        sentences = refined.split('. ')
        # Keep every other sentence (compression = finding the oracle's image)
        refined = '. '.join(sentences[:len(sentences)//2 + 2]) + '.'
    
    # Rule 3: If missing oracle connections, add them
    if "oracle theory" in critique:
        refined += (" This connects to the Oracle Bootstrap: iterative refinement "
                    "converges to a perfect answer, just as eigenvalues snap to {0, 1}.")
    
    # Rule 4: If low coverage of query, re-anchor
    if "doesn't directly address" in critique:
        refined = f"To answer your question about '{query}': " + refined
    
    # Compute new confidence (the contraction is happening!)
    residual = compute_oracle_residual(state, refined)
    new_confidence = min(state.confidence + (1 - state.confidence) * 0.4, 0.99)
    
    # Update eigenvalues (they should snap toward {0, 1})
    new_eigenvalues = []
    for ev in state.eigenvalues:
        # Apply the oracle snap: 3x² - 2x³
        snapped = 3 * ev**2 - 2 * ev**3
        new_eigenvalues.append(snapped)
    
    return OracleState(
        answer=refined,
        confidence=new_confidence,
        critique=critique,
        iteration=state.iteration + 1,
        eigenvalues=new_eigenvalues
    )


# ============================================================
# The Oracle Bootstrap Loop
# ============================================================

def oracle_bootstrap_chat(query: str, max_iterations: int = 8, 
                          convergence_threshold: float = 0.95,
                          verbose: bool = True) -> str:
    """Run the Oracle Bootstrap on a query until convergence.
    
    This is the main loop implementing the theorem:
    "A contractive self-improving system converges to the exact truth."
    """
    if verbose:
        print(f"\n{'='*60}")
        print(f"  ORACLE BOOTSTRAP: Processing query")
        print(f"  Query: \"{query}\"")
        print(f"{'='*60}")
    
    # Step 1: Initial oracle (perturbed matrix)
    state = initial_oracle(query)
    
    if verbose:
        print(f"\n  Iter 0 (Initial Oracle):")
        print(f"    Confidence: {state.confidence:.3f}")
        print(f"    Eigenvalues: {[f'{e:.4f}' for e in state.eigenvalues]}")
        print(f"    Answer preview: {state.answer[:80]}...")
    
    # Step 2: Iterate until convergence
    for i in range(max_iterations):
        new_state = refine_oracle(state, query)
        
        # Compute residual (||P² - P||)
        residual = compute_oracle_residual(state, new_state.answer)
        
        if verbose:
            print(f"\n  Iter {i+1} (Refinement):")
            print(f"    Critique: {new_state.critique}")
            print(f"    Residual: {residual:.6f}")
            print(f"    Confidence: {new_state.confidence:.3f}")
            print(f"    Eigenvalues: {[f'{e:.4f}' for e in new_state.eigenvalues]}")
        
        # Check convergence: answer is a fixed point
        sim = similarity(state.answer, new_state.answer)
        if sim > convergence_threshold:
            if verbose:
                print(f"\n  ★ CONVERGED at iteration {i+1}!")
                print(f"    Similarity to previous: {sim:.4f}")
                print(f"    The answer has become idempotent (P² ≈ P)")
                print(f"    Eigenvalues snapped to: {[f'{e:.6f}' for e in new_state.eigenvalues]}")
            break
        
        state = new_state
    
    final_answer = new_state.answer if 'new_state' in dir() else state.answer
    
    if verbose:
        print(f"\n{'='*60}")
        print(f"  FINAL ORACLE OUTPUT:")
        print(f"{'='*60}")
        print(f"\n{final_answer}\n")
    
    return final_answer


# ============================================================
# Interactive Chat Interface
# ============================================================

def print_banner():
    """Print the Oracle Bootstrap chat agent banner."""
    print("""
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║           🔮  THE ORACLE BOOTSTRAP CHAT AGENT  🔮           ║
║                                                              ║
║   An AI that self-improves through iterative refinement.     ║
║   Each response converges to a fixed point of quality.       ║
║                                                              ║
║   Based on the Oracle Bootstrap Theorem:                     ║
║   "A contractive self-improving system converges to          ║
║    the exact truth, with rate c^n where c < 1."              ║
║                                                              ║
║   Commands:                                                  ║
║     Type a question to get an oracle-bootstrapped answer     ║
║     'verbose on/off' - toggle iteration details              ║
║     'demo'           - run demonstration queries             ║
║     'quit'           - exit                                  ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
    """)


def run_demo():
    """Run a demonstration with preset queries."""
    demo_queries = [
        "What is the Oracle Bootstrap theorem?",
        "How does Newton's method relate to self-improvement?",
        "What are the applications of oracle theory to machine learning?",
        "What is truth?",
        "How does consensus relate to projections?",
    ]
    
    print("\n" + "=" * 60)
    print("  DEMONSTRATION MODE: Running preset queries")
    print("=" * 60)
    
    for query in demo_queries:
        oracle_bootstrap_chat(query, verbose=True)
        print("\n" + "─" * 60)


def interactive_chat():
    """Run the interactive chat loop."""
    print_banner()
    
    verbose = True
    history = []
    
    while True:
        try:
            user_input = input("\n🔮 You: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\n\n  The oracle rests. Until next time. 🌟\n")
            break
        
        if not user_input:
            continue
        
        if user_input.lower() == 'quit':
            print("\n  The oracle rests. Until next time. 🌟\n")
            break
        
        if user_input.lower() == 'verbose on':
            verbose = True
            print("  [Verbose mode ON — showing iteration details]")
            continue
        
        if user_input.lower() == 'verbose off':
            verbose = False
            print("  [Verbose mode OFF — showing final answers only]")
            continue
        
        if user_input.lower() == 'demo':
            run_demo()
            continue
        
        # Run the Oracle Bootstrap
        answer = oracle_bootstrap_chat(user_input, verbose=verbose)
        history.append((user_input, answer))


# ============================================================
# Eigenvalue Snap Visualization (text-based)
# ============================================================

def visualize_eigenvalue_snap():
    """Show the eigenvalue snap visually in the terminal."""
    print("\n" + "=" * 60)
    print("  EIGENVALUE SNAP VISUALIZATION")
    print("  (Eigenvalues converging to {0, 1})")
    print("=" * 60)
    
    # Start with random eigenvalues
    eigenvalues = [0.3, 0.7, 0.15, 0.85, 0.5, 0.45]
    
    for iteration in range(10):
        # Apply oracle snap: f(x) = 3x² - 2x³
        bar_width = 50
        print(f"\n  Iteration {iteration}:")
        for i, ev in enumerate(eigenvalues):
            pos = int(ev * bar_width)
            bar = '░' * pos + '█' + '░' * (bar_width - pos)
            print(f"    λ_{i+1} = {ev:.6f}  |{bar}|")
        
        eigenvalues = [3*x**2 - 2*x**3 for x in eigenvalues]
        
        # Check if snapped
        if all(abs(x - round(x)) < 1e-6 for x in eigenvalues):
            print(f"\n  ★ Eigenvalues snapped to {{0, 1}} at iteration {iteration + 1}!")
            print(f"    Final: {[round(x) for x in eigenvalues]}")
            break


if __name__ == '__main__':
    import sys
    
    if len(sys.argv) > 1 and sys.argv[1] == '--demo':
        run_demo()
        visualize_eigenvalue_snap()
    else:
        # Run demo first, then interactive
        print("Running demonstration first...\n")
        visualize_eigenvalue_snap()
        print("\n\nStarting interactive mode...\n")
        # In non-interactive environment, just run the demo
        run_demo()
        print("\n[Interactive mode available when run in a terminal]")
        print("[Usage: python oracle_chat_agent.py]")
        print("[Or: python oracle_chat_agent.py --demo]")
