# When Prime Numbers Behave Like Light: A Computer-Verified Discovery Connecting Optics, Quantum Physics, and Number Theory

*How treating prime numbers as optical gratings reveals a hidden symmetry — and a connection to one of the deepest conjectures in mathematics*

---

## The Prime Numbers' Secret Geometry

Imagine you could line up the prime numbers — 2, 3, 5, 7, 11, 13, ... — as tiny slits on a piece of glass, then shine light through them. What pattern would appear on the wall?

This is not a frivolous question. The mathematics of light passing through slits (diffraction) is identical to the mathematics of exponential sums, one of the most powerful tools in analytic number theory. The "fringe pattern" produced by primes encodes deep information about how primes are distributed — information that connects to one of the greatest unsolved problems in mathematics.

A team of researchers has now formalized this connection using a computer proof assistant, producing machine-verified theorems that link the "optical behavior" of prime numbers to a prediction from quantum physics: Montgomery's pair correlation conjecture.

## Two Tribes of Primes

Not all primes are created equal. Mathematicians have long known that the odd primes split into two distinct families:

- **Light primes**: 5, 13, 17, 29, 37, 41, 53, ... (primes that leave remainder 1 when divided by 4)
- **Dark primes**: 3, 7, 11, 19, 23, 31, 43, ... (primes that leave remainder 3 when divided by 4)

The light primes have a special algebraic property: each one can be written as the sum of two perfect squares. For example, 5 = 1² + 2², 13 = 2² + 3², 29 = 2² + 5². Dark primes cannot. This fact, proved by Pierre de Fermat in the 17th century, means that light primes have a hidden two-dimensional structure — they live naturally in a number system called the Gaussian integers, where each one splits into two conjugate factors.

The question is: does this algebraic distinction show up in the primes' "light pattern"?

## The Diffraction Experiment

When researchers computed the "diffraction pattern" of the first four light primes {5, 13, 17, 29} and compared it to the first four dark primes {3, 7, 11, 19}, they found something striking:

**Light primes produce a flatter, more uniform pattern. Dark primes produce a spikier, more concentrated pattern.**

The measure they used is called the *Sidon defect* — it counts how many "repeated spacings" exist between the numbers. A perfectly uniform set (called a "Sidon set") would have a defect of zero, meaning every spacing between pairs is unique. The light primes scored a defect of 2; the dark primes scored 4.

This pattern persisted at every scale they tested — 4 primes, 5 primes, 6 primes, 8 primes. The light primes consistently behaved more like a random, uniform set.

## The Autocorrelation Energy

To quantify this more precisely, the researchers defined the "autocorrelation energy" of a set — a single number that measures how concentrated its spacing pattern is. Think of it as measuring how "laser-like" vs "white-light-like" a set's diffraction pattern is:

| Prime Set | Size | Energy |
|-----------|------|--------|
| Light primes ≤ 29 | 4 | **32** |
| Dark primes ≤ 19 | 4 | 36 |
| Light primes ≤ 41 | 6 | **98** |
| Dark primes ≤ 31 | 6 | 110 |
| Light primes ≤ 61 | 8 | **220** |
| Dark primes ≤ 47 | 8 | 228 |

At every scale, the light primes have lower energy — their pattern is more uniform, more "white-light-like."

## The Montgomery Connection

In 1973, Hugh Montgomery made a remarkable conjecture about the Riemann zeta function — the most important function in number theory. He predicted that the spacings between the zeros of this function follow the same statistical pattern as the spacings between energy levels of atomic nuclei.

This prediction comes from random matrix theory, a branch of mathematics originally developed to describe quantum systems. The specific distribution is called the GUE (Gaussian Unitary Ensemble), and it has a characteristic feature: *repulsion*. Nearby energy levels push each other apart, creating a more uniform distribution than pure randomness would produce.

If Montgomery is right, the primes — which are intimately connected to the zeta function's zeros — inherit this repulsion. And repulsion leads to exactly the kind of flat, uniform diffraction pattern that the researchers observed for light primes.

**The chain of reasoning:**

1. Montgomery's conjecture says zero spacings follow GUE statistics
2. GUE statistics feature eigenvalue repulsion
3. Repulsion creates uniform gap distributions in the primes
4. Uniform gaps mean flat diffraction patterns
5. Flat diffraction means Sidon-like behavior (all differences distinct)

The researchers formalized steps 3-5 completely, proving them as rigorous mathematical theorems verified by computer.

## The Grand Hypothesis

The researchers propose what they call the *Light Primes Hypothesis*: the primes p ≡ 1 (mod 4) approach the random/Sidon limit faster than the primes p ≡ 3 (mod 4), because their Gaussian integer splitting distributes their additive structure into two dimensions.

Think of it this way: if you scatter dots on a line, they inevitably create clusters and gaps. But if you scatter dots on a plane and then project them onto a line, the projected pattern is more uniform — the extra dimension acts as a "randomizer."

Light primes naturally live on a two-dimensional lattice (the Gaussian integers). When we project them onto the number line, they inherit this two-dimensional uniformity. Dark primes have no such luxury — they are fundamentally one-dimensional objects.

## Machine-Verified Mathematics

What makes this work unusual is that every theorem is verified by a computer. The researchers used Lean 4, a proof assistant that checks mathematical arguments with absolute rigor. The computer verified:

- The diffraction framework (amplitude, intensity, autocorrelation)
- The Sidon defect calculations
- The autocorrelation energy bounds
- Fermat's theorem connecting light primes to sums of two squares
- The coherence comparison between light and dark primes

There are zero unproven claims in the formalization — every `sorry` (a placeholder for an unfinished proof) has been eliminated.

This level of verification is important because the claims touch on deep, unresolved questions in mathematics. Machine verification ensures that at minimum, the formalized theorems are logically correct, even as the broader conjectures remain open.

## What It All Means

The connection between prime numbers, light waves, and quantum mechanics is more than a metaphor. The mathematical structures are identical:

| Physics | Number Theory |
|---------|---------------|
| Diffraction grating | Set of primes |
| Wave amplitude | Exponential sum |
| Fringe intensity | Squared modulus |
| Autocorrelation | Patterson function |
| White light (flat) | Sidon set |
| Laser (peaked) | Arithmetic progression |
| GUE repulsion | Montgomery's conjecture |

The prime numbers, it seems, behave like a diffraction grating that nature has optimized — not for any particular frequency, but for a kind of universal flatness. And the light primes, those that split in the Gaussian integers, are the part of this grating that is closest to perfection.

Whether this connection can be made fully rigorous — proving that light primes really do converge to Sidon-like behavior faster than dark primes — remains one of the beautiful open questions at the intersection of algebra, analysis, and physics.

---

*The complete machine-verified formalization is available as Lean 4 source code in the project repository.*
