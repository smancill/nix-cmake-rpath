#include "hello_lib.hpp"

#include <json/json.h>

std::string hello(const std::string name)
{
    auto root = Json::Value{};
    root["greeting"] = "Hello";
    root["name"] = name;

    auto builder = Json::StreamWriterBuilder{};
    return Json::writeString(builder, root);
}
