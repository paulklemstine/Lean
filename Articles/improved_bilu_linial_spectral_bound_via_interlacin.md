# When Minus Signs Tame a Graph: The Story of the Unbalanced Square

## A puzzle about vibration

Imagine a network — cities linked by roads, atoms bonded in a molecule, neurons wired in a brain. Mathematicians capture such a network with a grid of numbers called the *adjacency matrix*: put a $1$ wherever two nodes are connected and a $0$ everywhere else. Hidden inside that grid are special numbers, its *eigenvalues*, which act like the natural frequencies of the network. Strike the network and it "rings" at these frequencies. The largest of them in absolute value — the *spectral radius* — measures how loudly the whole structure resonates. A small spectral radius means a network that is beautifully balanced, mixes information quickly, and resists congestion. Such graphs are the gold standard of connectivity, the mathematical backbone of error-correcting codes, fast algorithms, and robust communication networks.

Here is the tension at the heart of our story. If every node touches at most $d$ neighbors, the spectral radius can be as large as $d$ but never larger. A perfectly regular network — every node with exactly $d$ links — actually *hits* this ceiling: its spectral radius equals $d$ exactly. That is the worst possible case. The dream is to push the resonance far below $d$, ideally down near $2\sqrt{d-1}$, the theoretical floor discovered in the theory of *Ramanujan graphs*. Reaching that floor is famously hard.

But there is a trick, and it is delightfully simple.

## The trick: give every road a sign

What if each connection could be either an *attraction* or a *repulsion*? Instead of writing $1$ on every edge, we are allowed to write $+1$ or $-1$ — our choice, edge by edge. This choice is called a *signing*. The resulting grid is a *signed adjacency matrix*, and it has its own eigenvalues and its own spectral radius.

Crucially, flipping some edges to $-1$ never adds new connections; it only introduces the possibility of *cancellation*. When a wave travels around the network and comes back to where it started, the plus and minus signs it picks up along the way can conspire to cancel out. Cancellation is the enemy of resonance. So a clever pattern of signs might quiet a network that would otherwise ring at full volume $d$.

This is the celebrated idea behind the **Bilu–Linial program**: for *every* network with maximum degree $d$, there exists a signing whose spectral radius is at most

$$2\sqrt{3(d-1)}.$$

Notice how much smaller this is than $d$ for large $d$: the bound grows like $\sqrt{d}$ rather than $d$. The existence of such magical sign patterns is what powers modern constructions of near-optimal networks. The proof is a probabilistic tour de force: it shows that if you flip each edge's sign by a fair coin toss, the *average* behavior over all possible sign patterns is tame, and therefore at least one specific pattern must be at least as good as the average. It is an existence proof — it guarantees a good signing exists without ever pointing to one.

That leaves a very human question. **Can we ever put our finger on an actual sign pattern and watch the resonance drop?** Not on average, not in probability — concretely, provably, for a specific network we can hold in our hand?

## The smallest possible witness

The answer is yes, and the cleanest example is almost embarrassingly small: a square.

Take four nodes arranged in a cycle — call them $0, 1, 2, 3$ — with edges joining $0\!-\!1$, $1\!-\!2$, $2\!-\!3$, and $3\!-\!0$. Every node has exactly two neighbors, so the maximum degree is $d = 2$. The ordinary, all-positive square resonates at its maximum: its spectral radius is exactly $2$. It is the worst case in miniature.

Now we sign it. Give three of the edges a $+1$ and one edge a $-1$:

$$\sigma(0,1) = +1,\quad \sigma(1,2) = +1,\quad \sigma(2,3) = +1,\quad \sigma(3,0) = -1.$$

The signed adjacency matrix becomes

$$B = \begin{pmatrix} 0 & 1 & 0 & -1 \\ 1 & 0 & 1 & 0 \\ 0 & 1 & 0 & 1 \\ -1 & 0 & 1 & 0 \end{pmatrix}.$$

What makes this signing special is a single number: the product of the signs all the way around the loop. Multiply them together and you get

$$(+1)(+1)(+1)(-1) = -1.$$

Because that product is negative, the square is called **unbalanced**. Balance and unbalance are the fundamental dichotomy of signed graphs. A *balanced* cycle (product $+1$) is a wolf in sheep's clothing — you can always relabel the nodes to erase every minus sign, so it behaves exactly like the plain unsigned graph and resonates just as loudly. An *unbalanced* cycle (product $-1$) is genuinely different: no relabeling can remove all its minus signs. The frustration is real and permanent, and it is precisely this frustration that suppresses resonance.

## The moment of cancellation

Here is where the magic becomes visible. Multiply the matrix $B$ by itself. A direct computation — just multiplying rows by columns — yields something startlingly clean:

$$B^2 = 2\,I,$$

where $I$ is the identity matrix. Squaring the signed square gives twice the identity. Nothing but $2$'s down the diagonal and $0$'s everywhere else.

Why does this happen? The entry of $B^2$ in position $(i, j)$ counts the *signed* two-step walks from node $i$ to node $j$. When $i \ne j$, the walks that could connect them arrive with opposite signs — thanks to that one negative edge — and annihilate each other perfectly. When $i = j$, the two round-trips to a node's two neighbors both contribute $+1$, adding up to $2$. The lone minus sign, placed just so, orchestrates a total cancellation off the diagonal. This is the whole Bilu–Linial philosophy compressed into a $4 \times 4$ computation you can do by hand.

The consequence for the eigenvalues is immediate. If $\mu$ is any frequency of $B$ — meaning $B v = \mu v$ for some nonzero vibration pattern $v$ — then applying $B$ twice multiplies $v$ by $\mu^2$. But applying $B$ twice is the same as multiplying by $B^2 = 2I$, which multiplies $v$ by $2$. Since $v$ is not the zero vector, the two must agree:

$$\mu^2 = 2, \qquad \text{so} \qquad |\mu| = \sqrt{2}.$$

**Every** eigenvalue of the unbalanced square has absolute value exactly $\sqrt{2}$. The spectral radius is precisely $\sqrt{2} \approx 1.414$.

## Small number, big meaning

Compare the two worlds. The unsigned square rings at $2$. The unbalanced square rings at $\sqrt{2}$. And $\sqrt{2}$ is *strictly* less than $2$ — a fact one proves in a line, since $(\sqrt 2)^2 = 2 < 4 = 2^2$. A single flipped sign has dropped the resonance by nearly thirty percent.

This is not a statistical statement about averages, and it does not rely on any coin-flipping or existence argument. It is a concrete, checkable, exact identity: this specific network, with this specific sign pattern, resonates at exactly $\sqrt 2$, comfortably under the ceiling of $2$ that the degree alone would impose. The trivial bound "spectral radius at most maximum degree" gives $|\mu| \le 2$; the truth is $\sqrt 2$. The unbalanced square is the smallest, sharpest witness that signing genuinely works.

It also illustrates the deterministic dream. The Bilu–Linial theorem promises a good signing exists but hides it inside a probabilistic haystack. The square shows that at least sometimes we can *construct* the needle directly: find a cycle, unbalance it, and watch the shortest closed walks cancel. The mechanism that the probabilistic method achieves only on average is here forced to happen exactly, by hand, through a single well-placed minus sign.

## Why the constant is $3(d-1)$, and where it might go

Step back to the general bound $2\sqrt{3(d-1)}$ and ask where the curious factor of $3$ comes from. The proof counts closed walks in the network — journeys that leave a node and return. Averaging over all random signings performs a ruthless act of bookkeeping: any walk that crosses some edge an *odd* number of times picks up an unpaired minus sign as often as a plus, and washes out to zero. Only the *even* walks — those traversing every edge an even number of times — survive the averaging. The growth rate of these even walks is governed by a branching factor of $3(d-1)$, and that factor is exactly what surfaces inside the square root.

This clean separation — an elementary averaging principle on one side, a hard walk-counting estimate on the other — is what makes the problem so alluring today. The averaging half is settled. The entire improved bound now rests on a single scalar question about how fast even closed walks proliferate. And there is reason to believe the true constant is smaller still. If one counts only *non-backtracking* walks — journeys that never immediately retrace the step they just took — the excess factor of $3$ is precisely the debris left by backtracking. Excising it should collapse the constant from $3(d-1)$ down to $d-1$, delivering the conjecturally optimal bound

$$2\sqrt{d-1}$$

for every regular network — the Ramanujan floor itself. The humble unbalanced square, ringing at $\sqrt 2$ instead of $2$, is the first visible step on that ladder: proof that the right minus sign, in the right place, can quiet a network on demand.

## The bigger picture

Signed graphs are far more than a curiosity. They model social networks where ties can be friendly or hostile, physical systems with competing forces, and quantum states with interfering paths. The question "can we sign the edges to minimize resonance?" is, at bottom, a question about engineering cancellation — about arranging opposition so cleverly that a system stays calm. The unbalanced square is the atom of this theory: the smallest arrangement in which a single conflict, correctly placed, produces global harmony. From it grows a whole program aimed at building the world's most efficient networks, one well-chosen minus sign at a time.
