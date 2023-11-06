---
layout: topic
title: Coin selection
---

## Notes

- Coin selection refers to the process of picking UTXOs from the wallet’s UTXO pool to fund a transaction. Ideally, we want to minimize the number of coins we spend at any one time.

- Since v23.0, Bitcoin Core runs Knapsack, [[Branch and Bound (BnB)]] and [[Single Random Draw (SRD)]] solvers in parallel and then choose among the three resulting input set candidates the one that scores best according to the [[waste metric]], which was previously already used to pick the best Branch and Bound solution.

- Beyond the primary goal of funding a transaction, the secondary goals of coin selection are:

    - Minimizing short term and long term fees
        - We pay fees based on the transaction fee, and more coins means bigger sizes and thus more fees.
        - We have to balance two needs: we want to pay the smallest fee now to get a timely confirmation, but we have to keep in mind that all of the wallet’s UTXOs will need to be spent at some point.
        - We shouldn’t over-optimize locally at the detriment of large future costs. E.g. always using largest-first selection minimizes the current cost, but grinds the wallet’s UTXO pool to dust.

    - Maintaining financial privacy
        - Every time we “aggregate” coins together, we connect the histories of the two outpoints to one owner, degrading the privacy of the system.
        - There are a number of heuristics that tracking companies employ to cluster payments and addresses. For example, using inputs with the same output script in two transactions indicates that the two transactions involved the same party.
        - Similarly, it is usually assumed that all inputs of a transaction were controlled by the same entity. Sometimes the privacy and economic considerations are opposed.

    - Help the transaction reliably confirm in a timely manner
        - Using unconfirmed inputs can make transactions unreliable. Unconfirmed transactions received from another wallet may time out or be replaced, making those funds disappear. 
        - Even using self-sent unconfirmed funds may delay the new transaction if the parent transaction has an extensive ancestry, is extraordinarily large, or used a lower feerate than targeted for the child transaction.

- We’re also incentivized to try to find coins so that the input is about the same as the output so we can skip making a new change output.

    - Why is it good to have no change output?
        - Because it uses less fees(also not creating a change output saves cost now, and then also saves the future cost of spending that UTXO at a later time), reduces the overall UTXO in the system, does not put any funds into flight in a change output (a change output is an additional unconfirmed UTXO we have to track, until the tx confirms). 
        - Breaks the change heuristic. A bunch of the chainalysis techniques revolve around guessing which output is the change returning excess funds from the input selection to the sender. When guessed correctly, this can be used to cluster future transactions with this one to build a wallet profile. By not returning any funds to the sender's wallet, there are no future transactions directly related to this transaction (unless addresses are reused)

- Notably, each candidate coin is considered using an [[effective value]], introduced in [[PR#17331]]. This deducts the cost to spend this input at the target feerate from its `nValue`.

<!-- uncomment to add
## History
-->

## Resources

- <https://bitcoinops.org/en/topics/coin-selection/>
- [What are the trade-offs between the different algorithms for deciding which UTXOs to spend?](https://bitcoin.stackexchange.com/questions/32145/what-are-the-trade-offs-between-the-different-algorithms-for-deciding-which-utxo)
- [Goals of Coin Selection and Overview of the Coin Selection algorithms](https://bitcoin.stackexchange.com/a/32445)