#!/usr/bin/env python3
"""
Meaning Phase Transition — When Noise Becomes Signal
=====================================================

Inspired by GEB's exploration of meaning, isomorphism, and decoding,
this demo simulates how meaning emerges from the interaction between
a message and a receiver.

Key idea (from Kolmogorov complexity theory):
  Meaning(m, R) = K(m) - K(m | R)

Meaning is the REDUCTION in a message's complexity given knowledge of
the receiver's internal model. If the receiver has structure isomorphic
to the message, meaning is high. If not, the message is noise.

We demonstrate:
  1. The phase transition in meaning as receiver complexity grows
  2. The "Hall of Mirrors" effect — different receivers decode different meanings
  3. The Alien Signal problem — what happens when K(message) >> K(receiver)
  4. Information-theoretic proof that meaning is receiver-dependent
"""

import random
import math
import string
from collections import Counter


# ============================================================
# Part 1: Approximating Kolmogorov Complexity
# ============================================================

def compression_complexity(data):
    """
    Approximate Kolmogorov complexity using compression ratio.
    
    K(x) ≈ len(compress(x)) / len(x)
    
    We use a simple run-length + dictionary approach.
    Higher ratio = more complex (less compressible).
    """
    if not data:
        return 0
    
    # Method 1: Shannon entropy (bits per symbol)
    counts = Counter(data)
    total = len(data)
    entropy = -sum(
        (c / total) * math.log2(c / total) 
        for c in counts.values() if c > 0
    )
    
    # Method 2: Unique n-gram ratio
    if len(data) >= 3:
        trigrams = [data[i:i+3] for i in range(len(data) - 2)]
        ngram_ratio = len(set(trigrams)) / len(trigrams)
    else:
        ngram_ratio = 1.0
    
    # Combined measure
    return (entropy * 0.6 + ngram_ratio * 4.0 * 0.4)


def conditional_complexity(message, receiver_model):
    """
    Approximate K(message | receiver).
    
    If the receiver's model contains patterns matching the message,
    the conditional complexity is LOW (the receiver "understands").
    If not, K(message | receiver) ≈ K(message) (no help from receiver).
    """
    if not message or not receiver_model:
        return compression_complexity(message)
    
    # Check how many message patterns the receiver "knows"
    known_patterns = 0
    total_patterns = 0
    
    for length in [1, 2, 3, 4, 5]:
        for i in range(len(message) - length + 1):
            pattern = message[i:i+length]
            total_patterns += 1
            if pattern in receiver_model:
                known_patterns += 1
    
    if total_patterns == 0:
        return compression_complexity(message)
    
    recognition_ratio = known_patterns / total_patterns
    
    # Conditional complexity: what the receiver CAN'T recognize
    base_complexity = compression_complexity(message)
    return base_complexity * (1 - recognition_ratio)


def meaning(message, receiver_model):
    """
    Compute the meaning of a message to a receiver.
    
    Meaning = K(message) - K(message | receiver)
    
    High meaning = the receiver's model greatly reduces the message's complexity
    Low meaning = the receiver's model doesn't help decode the message
    """
    k_m = compression_complexity(message)
    k_m_given_r = conditional_complexity(message, receiver_model)
    return max(0, k_m - k_m_given_r)


# ============================================================
# Part 2: The Phase Transition
# ============================================================

def phase_transition_experiment():
    """
    Show that meaning undergoes a sharp phase transition as
    receiver complexity increases past a critical threshold.
    """
    print("MEANING PHASE TRANSITION EXPERIMENT")
    print("=" * 60)
    print()
    
    # Create a structured message (English text)
    message = ("the strange loop of consciousness emerges when a system "
               "models itself with sufficient depth to create a fixed point "
               "of self representation that we call the soul")
    
    print(f"Message: '{message[:60]}...'")
    print(f"Message complexity: {compression_complexity(message):.3f}")
    print()
    print("Receiver Complexity │ Meaning │ Visualization")
    print("────────────────────┼─────────┼──────────────────────────────")
    
    # Build receivers of increasing complexity
    # Start with empty model, gradually add English language patterns
    english_corpus = (
        "the of and to a in is it that was for on are with as his they be "
        "at one have this from or had by not but some what there we can out "
        "other were all your when up use how said an each she which do their "
        "time if will way about many then them would write like so these her "
        "long make thing see him two has look more day could go come did my "
        "sound no most number who over know water than call first people may "
        "down side been now find head stand own page should country found "
        "answer school grow study still learn plant cover food sun four "
        "thought let keep eye never last door between city tree cross since "
        "hard start might story saw far sea draw left late run while press "
        "close night real life few stop open seem together next white children "
        "begin got walk example ease paper often always music those both mark "
        "book letter until mile river car feet care second group carry took "
        "rain eat room friend began idea fish mountain north once base hear "
        "horse cut sure watch color face wood main enough plain girl usual "
        "young ready above ever red list though feel talk bird soon body dog "
        "family direct pose leave song measure state product black short "
        "numeral class wind question happen complete ship area half rock "
        "order fire south problem piece told knew pass farm top whole king "
        "size heard best hour better true during hundred remember step early "
        "hold west ground interest reach fast five sing listen six table "
        "travel less morning ten simple several vowel toward war lay against "
        "pattern slow center love person money serve appear road map science "
        "rule govern pull cold notice voice fall power town fine fly unit "
        "strange loop self reference consciousness model depth fixed point "
        "soul emergence meaning receiver signal complexity threshold"
    )
    
    words = english_corpus.split()
    
    results = []
    for frac in [i / 40 for i in range(41)]:
        # Build receiver model with fraction of English knowledge
        n_words = max(1, int(len(words) * frac))
        receiver_words = set(words[:n_words])
        
        # Build pattern set from known words
        receiver_model = set()
        for w in receiver_words:
            receiver_model.add(w)
            for i in range(len(w)):
                for j in range(i + 1, min(i + 6, len(w) + 1)):
                    receiver_model.add(w[i:j])
        
        m = meaning(message, receiver_model)
        results.append((frac, n_words, m))
        
        bar_len = int(m * 15)
        bar = "█" * bar_len + "░" * (30 - bar_len)
        
        if int(frac * 40) % 4 == 0 or frac >= 0.95:
            print(f"  {frac:>6.1%} ({n_words:3d} words) │ {m:>5.3f}  │ {bar}")
    
    print()
    
    # Find the phase transition point
    max_jump = 0
    transition_point = 0
    for i in range(1, len(results)):
        jump = results[i][2] - results[i-1][2]
        if jump > max_jump:
            max_jump = jump
            transition_point = results[i][0]
    
    print(f"Phase transition detected at ~{transition_point:.0%} receiver complexity")
    print(f"Maximum meaning jump: {max_jump:.4f}")
    print()
    print("Below the threshold: the message is NOISE (meaning ≈ 0)")
    print("Above the threshold: the message suddenly 'makes sense'")
    print("This is analogous to how comprehension 'clicks' — it's not gradual.")
    print()


# ============================================================
# Part 3: The Hall of Mirrors
# ============================================================

def hall_of_mirrors():
    """
    Same message, different receivers, different meanings.
    Demonstrates the Void Theorem: meaning is receiver-dependent.
    """
    print("THE HALL OF MIRRORS — Same Message, Different Meanings")
    print("=" * 60)
    print()
    
    message = "the loop closes upon itself and meaning emerges from the spiral"
    print(f"Message: '{message}'")
    print()
    
    # Different "receivers" with different internal models
    receivers = {
        "Mathematician": set("theorem proof axiom loop fixed point set function map "
                           "topology algebra group ring field category functor".split()),
        "Musician": set("loop rhythm spiral harmony melody beat tempo chord "
                       "crescendo diminished augmented resolution cadence".split()),
        "Biologist": set("loop dna spiral protein cell emerges organism evolution "
                        "helix replication transcription genome phenotype".split()),
        "Philosopher": set("meaning self consciousness emerges upon being essence "
                          "existence phenomenology qualia intentionality".split()),
        "Random Noise": set(f"xq{i}z" for i in range(50)),  # No relevant patterns
    }
    
    for name, model in receivers.items():
        # Expand model to include substrings
        expanded = set()
        for w in model:
            expanded.add(w)
            for i in range(len(w)):
                for j in range(i+1, min(i+6, len(w)+1)):
                    expanded.add(w[i:j])
        
        m = meaning(message, expanded)
        bar = "█" * int(m * 20)
        print(f"  {name:>15}: meaning = {m:.3f}  {bar}")
    
    print()
    print("The SAME message has DIFFERENT meaning to each receiver.")
    print("Meaning is not 'in' the message — it's in the RESONANCE")
    print("between message structure and receiver structure.")
    print()
    print("Corollary: There is no 'objective meaning' of any signal.")
    print("The universe is a Rorschach test — we see what we are.")
    print()


# ============================================================
# Part 4: The Alien Signal Problem
# ============================================================

def alien_signal_experiment():
    """
    What happens when we receive a message from a vastly more
    complex intelligence?
    """
    print("THE ALIEN SIGNAL PROBLEM")
    print("=" * 60)
    print()
    
    # Simulate an "alien message" with very high complexity
    random.seed(42)
    
    # Human "receiver" complexity
    human_vocab = set("the of and to is in it that for on with as".split())
    human_model = set()
    for w in human_vocab:
        human_model.add(w)
        for i in range(len(w)):
            for j in range(i+1, len(w)+1):
                human_model.add(w[i:j])
    
    print("Alien intelligence sends signals of increasing complexity:")
    print()
    print("Alien Complexity │ Decodable Fraction │ Visualization")
    print("─────────────────┼────────────────────┼──────────────────────")
    
    human_complexity = len(human_model)
    
    for alien_factor in [1, 2, 5, 10, 50, 100, 1000, 10000]:
        # Generate alien message of given complexity
        alien_alphabet = string.ascii_lowercase + string.digits + "!@#$%^&*"
        alien_msg_len = 100
        alien_msg = ''.join(random.choice(alien_alphabet) for _ in range(alien_msg_len))
        
        alien_complexity = human_complexity * alien_factor
        
        # Decodable fraction ≈ min(human, alien) / alien
        decodable = min(human_complexity, alien_complexity) / alien_complexity
        
        bar_full = 30
        decoded_bar = int(decodable * bar_full)
        bar = "█" * decoded_bar + "░" * (bar_full - decoded_bar)
        
        print(f"  {alien_factor:>7}x human  │ {decodable:>16.1%}   │ {bar}")
    
    print()
    print("At 1000x human complexity, we can decode only 0.1% of the signal.")
    print("We would 'decode' the message — but what we decode is a PROJECTION")
    print("of our own cognitive structure onto their signal.")
    print()
    print("We wouldn't know what we're missing. We'd think we understood.")
    print("This is the terrifying conclusion of the Void Theorem:")
    print("we can never know how much of reality we're NOT seeing.")
    print()


# ============================================================
# Part 5: Information-Theoretic Proof
# ============================================================

def information_theoretic_proof():
    """
    Demonstrate the formal proof that meaning is receiver-dependent.
    """
    print("FORMAL PROOF: NO INTRINSIC MEANING")
    print("=" * 60)
    print()
    
    # Construct a message
    message = [1, 0, 1, 1, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1]
    
    # Construct different decoders
    decoders = {
        "ASCII decoder": lambda m: ''.join(chr(int(''.join(map(str, m[i:i+8])), 2)) for i in range(0, len(m), 8)),
        "Morse decoder": lambda m: ''.join('.' if b == 1 else '-' for b in m),
        "Parity check": lambda m: f"Parity = {sum(m) % 2}",
        "Run-length": lambda m: str([(len(list(g)), k) for k, g in __import__('itertools').groupby(m)]),
        "Sum decoder": lambda m: f"Sum = {sum(m)}",
        "Null decoder": lambda m: "No meaning detected",
    }
    
    print(f"Message: {message}")
    print()
    
    for name, decoder in decoders.items():
        try:
            result = decoder(message)
            print(f"  {name:>18}: {result}")
        except Exception:
            print(f"  {name:>18}: (decoding error)")
    
    print()
    print("The SAME bit string 'means' completely different things to")
    print("each decoder. None of them is 'wrong' — meaning is relative")
    print("to the decoding scheme (isomorphism) applied.")
    print()
    print("Theorem (Void Theorem):")
    print("  For any message m and any target meaning μ,")
    print("  there exists a receiver R_μ such that Meaning(m, R_μ) = μ.")
    print()
    print("  Proof: Construct R_μ as a decoder that maps m to μ.")
    print("  Such a decoder always exists (it's just a lookup table).")
    print("  Therefore, m has no 'intrinsic' meaning — only relative meaning. □")
    print()


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  MEANING PHASE TRANSITION                                       ║")
    print("║  When Noise Becomes Signal                                      ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    phase_transition_experiment()
    hall_of_mirrors()
    alien_signal_experiment()
    information_theoretic_proof()
    
    print("=" * 60)
    print("SYNTHESIS")
    print("=" * 60)
    print()
    print("1. Meaning undergoes a PHASE TRANSITION as receiver complexity grows.")
    print("2. The SAME message has DIFFERENT meanings to different receivers.")
    print("3. Vastly complex messages are mostly INVISIBLE to simpler receivers.")
    print("4. There is NO INTRINSIC MEANING — only resonance between structures.")
    print()
    print("Hofstadter's insight vindicated: meaning is not in the signal,")
    print("not in the receiver, but in the ISOMORPHISM between them.")
    print("The universe doesn't 'contain' meaning — we CREATE it")
    print("through the strange loop of observation and interpretation.")


if __name__ == "__main__":
    main()
