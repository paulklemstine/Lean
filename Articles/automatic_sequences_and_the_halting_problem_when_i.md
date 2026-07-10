# When Can a Machine Know a Sequence Never Hits Zero?

## A tiny machine with a big question

Imagine a sequence of numbers stretching off to infinity:

$$0,\,1,\,1,\,0,\,1,\,0,\,0,\,1,\,1,\,0,\,0,\,1,\,0,\,1,\,1,\,0,\,\dots$$

This is the **Thue–Morse sequence**, and there is a delightfully simple rule behind it. Write a whole number $n$ in binary, count how many $1$s appear, and record whether that count is even ($0$) or odd ($1$). So $n = 3$ is $11$ in binary, which has two $1$s (even), giving $0$; while $n = 4$ is $100$, one $1$ (odd), giving $1$. Run this over $n = 0, 1, 2, 3, \dots$ and out tumbles the sequence above.

What makes Thue–Morse special is not the arithmetic but the *machinery*. You do not need a powerful computer to produce it. A pocket-sized gadget with just **two internal states** suffices. Feed it the binary digits of $n$ one at a time; it flips between "even so far" and "odd so far" with each $1$ it reads, ignores every $0$, and reports its final state. Sequences that can be produced by such a finite, memoryless-except-for-a-handful-of-states gadget are called **automatic sequences**, and they sit at a fascinating crossroads of number theory, computer science, and logic.

This article is about a deceptively simple question you can ask of any such sequence:

> **Does the value $0$ ever appear?**

And a subtler cousin:

> **Does the value $0$ appear infinitely often?**

For general computational processes, questions like these are the stuff of the famous **halting problem** — provably impossible for a machine to answer in all cases. The surprise, and the heart of this story, is that for automatic sequences these questions are *completely decidable*. There is a finite recipe that always terminates with the correct yes-or-no answer. We will see exactly why — and we will also fix a piece of folklore that, though widely repeated, is simply false.

## Finite automata: computing with almost no memory

The gadget behind Thue–Morse is a **deterministic finite automaton**, or **DFA**. Strip it to essentials and a DFA is four things:

- a finite set of **states** $\sigma$ (Thue–Morse uses two: "even" and "odd");
- an **alphabet** of input symbols (for Thue–Morse, the binary digits $0$ and $1$);
- a **transition rule** that, given the current state and the next input symbol, dictates the next state;
- a designated **start state** and a set of **accepting states**.

You run a DFA on a finite word — a string of symbols — by starting in the start state and following the transition rule symbol by symbol. If you finish in an accepting state, the machine **accepts** the word; otherwise it **rejects**. The collection of all accepted words is the machine's **language**.

For the Thue–Morse machine, the input word is the binary expansion of $n$, the transition rule is "flip on $1$, stay on $0$," the start state is "even," and the single accepting state is "odd." The word for $n$ is accepted exactly when the digit sum is odd — exactly when the $n$-th term of the sequence is $1$. So asking "**is any term equal to $1$?**" is the same as asking "**does the machine accept any word at all?**", and asking "**is any term equal to $0$?**" is the same question for the complementary machine (swap accepting and non-accepting states). In every case, the value-hunting question about a sequence becomes a **nonemptiness question about a language**: *does this automaton accept at least one word?*

That translation is the whole game. If we can decide language nonemptiness, we can decide whether a value ever occurs.

## The pigeonhole heart of the matter

Here is the key intuition. A DFA has only finitely many states — say $s$ of them. Suppose it accepts some word. Watch the machine trace its path through the states as it reads that word. If the word is long — specifically, if it has length $s$ or more — then the machine visits **more states-along-the-way than it has states**. By the pigeonhole principle, it must return to a state it has already been in. It has gone in a **loop**.

That single observation drives everything.

**Loops can be cut out.** If the path revisits a state, the chunk of the word between the two visits drove the machine in a circle, landing it right back where it started. Snip that chunk out, and the shortened word steers the machine along the very same overall route to the very same final state. So it is *still accepted*. This is the "pump down" move: any accepted word of length $\ge s$ can be trimmed to a strictly shorter accepted word.

Repeat the trimming, and you cannot go forever — lengths are whole numbers and keep decreasing — so you eventually reach an accepted word of length **less than $s$**. This yields our first landmark result.

> **Reachability Bound.** *A finite automaton's language is nonempty if and only if it accepts some word shorter than its number of states.*

The payoff is immediate. There are only finitely many words shorter than $s$ (over a finite alphabet). To decide whether the machine accepts anything, **check them all**. The search is finite and always terminates. Hence:

> **Decidability of "Zero in the Sequence."** *For any automatic sequence, it is decidable whether a given value ever occurs: translate the value-search into a language-nonemptiness question and test all words shorter than the number of states.*

No halting problem, no undecidability — just an honest finite search with a guaranteed answer.

## The same loop, run the other way

The pigeonhole loop also runs *forward*. Take the chunk of word that drove the machine in a circle. Instead of deleting it, **repeat it**. Two laps around the loop, three, a hundred — each returns the machine to the same state, so each produces a new, longer accepted word. One loop therefore begets infinitely many accepted words.

> **Pump Up.** *If a finite automaton accepts even a single word of length $\ge s$, its language is infinite.*

Combine pumping up with pumping down and you get a clean characterization of when infinitely many terms take a value:

> **Infinitude Criterion.** *A finite automaton's language is infinite if and only if it accepts some word of length at least $s$ (the number of states).*

And there is a sharpened version that makes the test practical. If any long word is accepted, you can pump it *down* until its length lands in the tidy window $[s,\,2s)$ — big enough to guarantee a loop, small enough to bound the search.

> **Bounded Infinitude Criterion.** *The language is infinite if and only if it accepts a word whose length lies between $s$ and $2s - 1$.*

Once again the criterion is a finite search, so:

> **Decidability of "Zero Infinitely Often."** *For any automatic sequence, it is decidable whether a given value occurs infinitely often: search the finitely many words of length below $2s$.*

## A myth, politely corrected

Textbooks and lecture notes sometimes offer a tempting shortcut: *"If a finite automaton accepts any word at all, it accepts infinitely many."* It sounds plausible — automata feel loopy and generative. **It is false.**

The counterexample is as small as they come. Take the two-state parity machine and ask it to accept only the single word $1$. It reads one symbol, lands in "odd," accepts, and that is the *only* word it ever accepts. Its language has exactly one element. Accepting *something* does not force accepting *infinitely many things*.

The correct statement is the dichotomy above: acceptance of *any* word gives you nonemptiness, but infinitude requires acceptance of a *long* word — one of length at least the number of states. The distinction is not pedantry. Nonemptiness and infinitude are genuinely different questions, each with its own witness length ($< s$ for existence, $\ge s$ for infinitude), and conflating them papers over the very pumping argument that makes the theory work.

## Back to Thue–Morse

Our two-state parity machine makes an excellent test case. It accepts the single word $1$, so its language is nonempty — the Thue–Morse sequence *does* contain the value $1$. It also accepts the length-$2$ word $10$, and since $2$ meets the "at least the number of states" threshold, the Infinitude Criterion certifies that its language is infinite: the value $1$ appears **infinitely often**. Both facts fall straight out of the general theory, with no need to inspect the sequence term by term.

The Thue–Morse sequence also wears its "automatic" nature on its sleeve through two elegant recurrences. Writing $t(n)$ for its $n$-th term (as a parity, so arithmetic is modulo $2$):

$$t(2n) = t(n), \qquad t(2n+1) = t(n) + 1.$$

The first says that appending a binary digit $0$ (which is what doubling does) leaves the digit-sum parity unchanged. The second says appending a $1$ (doubling and adding one) flips it. Together they imply that consecutive pairs always disagree — $t(2n) \ne t(2n+1)$ for every $n$ — the signature restlessness that makes Thue–Morse never settle into a repeating pattern.

## Where the ground gives way

The clean decidability we have described marks a genuine frontier in the theory of sequences. Automatic sequences are the ones a finite automaton can generate, and for them the value-occurrence questions are decidable, full stop. Push just past this class — to **morphic sequences**, produced by iterating a symbol-substitution rule and then relabeling — and the picture clouds over. Morphic sequences are strictly more expressive; many natural sequences are morphic but not automatic. For them, whether the "does zero ever appear?" question is decidable in general is a genuine **open problem**.

That is the deeper lesson. The boundary between *decidable* and *undecidable* in the world of sequences runs right along the boundary between *automatic* and *morphic*. On the automatic side, a finite pigeonhole argument tames every value-occurrence question. On the morphic side, the loops grow subtle enough that no one yet knows whether a universal recipe exists. Cryptographers and coding theorists care because automatic sequences — Thue–Morse, Rudin–Shapiro, the paperfolding sequence — supply low-correlation, easily generated pseudorandom strings whose structural questions we can actually *answer*. Knowing exactly which questions a small machine can settle, and where that power runs out, is knowing the shape of computation itself.

The machine is tiny. The question it can answer — *will this ever be zero?* — is enormous. That such a small device can put such a large question to rest, while its slightly bigger cousin cannot, is one of the quiet marvels at the edge of the computable.
