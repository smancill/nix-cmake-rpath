#include "hello_lib.hpp"

#include <iostream>

int main(int, char**)
{
    auto expected = R"JSON({
	"greeting" : "Hello",
	"name" : "Nix"
})JSON";

    auto result = hello("Nix");
    if (result == expected) {
        return 0;
    }
    return 1;
}
