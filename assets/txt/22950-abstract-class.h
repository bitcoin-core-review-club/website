#include <iostream>

class PeerManager
{
public:
    static std::unique_ptr<PeerManager> make(int ctor_int);
    virtual ~PeerManager() {}

    virtual void SetBestHeight(int height) = 0;

    virtual int GetMax(int a, int b) const = 0;
    virtual long GetMax(long a, long b) const = 0;
};
