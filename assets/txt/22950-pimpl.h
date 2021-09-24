#include <iostream>

class TxRequestTracker {
    class Impl;
    const std::unique_ptr<Impl> m_impl;

public:
    explicit TxRequestTracker(int i);
    ~TxRequestTracker();

    void Count(int peer_id) const;

    template <typename T>
    T GetMax(T a, T b);
};
