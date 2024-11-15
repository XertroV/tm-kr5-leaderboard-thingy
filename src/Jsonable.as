interface Jsonable {
    Json::Value@ toJson();
    void fromJson(Json::Value@ j);
}
