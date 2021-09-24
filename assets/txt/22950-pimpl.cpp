#include <iostream>
#include "pimpl.h"

class TxRequestTracker::Impl {
    int my_i;

public:
    Impl(int i) : my_i(i) {}
    ~Impl() {}

    void Count(int peer_id) const {
        auto val = (peer_id == my_i) ? "yup" : "nope";
        std::cout << val << std::endl;
    }

    template <typename T>
    T GetMax(T a, T b);

};

template <typename T>
T TxRequestTracker::Impl::GetMax(T a, T b) {
    T result;
    result = (a > b) ? a : b;
    return result;
}

TxRequestTracker::TxRequestTracker(int i)
    : m_impl(std::make_unique<TxRequestTracker::Impl>(i)) {}

TxRequestTracker::~TxRequestTracker() = default;

void TxRequestTracker::Count(int peer_id) const { return m_impl->Count(peer_id); }

template <typename T>
T TxRequestTracker::GetMax(T a, T b) {
   return m_impl->GetMax<T>(a, b);
}

int main() {
    TxRequestTracker m_txrequest{3};
    m_txrequest.Count(8);
    m_txrequest.Count(3);

    std::cout << m_txrequest.GetMax<int>(4, 6) << std::endl;
    std::cout << m_txrequest.GetMax<long>(4, 6) << std::endl;

    return 0;
}
