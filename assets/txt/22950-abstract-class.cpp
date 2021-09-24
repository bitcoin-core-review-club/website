#include <iostream>
#include "pimpl2.h"


class PeerManagerImpl final : public PeerManager {
    int m_best_height;

public:
    PeerManagerImpl(int ctor_int);

    void SetBestHeight(int height) override {
        m_best_height = height;
        std::cout << "setting m_best_height to " << height << std::endl;
    };

    int GetMax(int a, int b) const override {
        return GetMax<int>(a, b);
    }

    long GetMax(long a, long b) const override {
        return GetMax<long>(a, b);
    }

    template <typename T>
    T GetMax(T a, T b) const;
};


template <typename T>
T PeerManagerImpl::GetMax(T a, T b) const
{
    T result;
    result = (a > b) ? a : b;
    return result;
}

std::unique_ptr<PeerManager> PeerManager::make(int caller_int)
{
    return std::make_unique<PeerManagerImpl>(caller_int);
}

PeerManagerImpl::PeerManagerImpl(int ctor_int)
    : m_best_height(ctor_int)
{
    std::cout << "impl ctor, m_best_height: " << ctor_int << std::endl;
}

int main() {
    auto peerman = PeerManager::make(3);
    peerman->SetBestHeight(4);
    peerman->SetBestHeight(11);

    std::cout << peerman->GetMax(4, 11) << std::endl;
    std::cout << peerman->GetMax((long)6, (long)11) << std::endl;

    return 0;
}
