library(mongolite)
library(ggplot2)

# Ejemplo Tweets
tweets <- mongo(
  collection = "tweets_mongo_covid19", 
  db = "DMUBA"
)

expanded_hashtags = tweets$aggregate(
  pipeline =   '[{ "$unwind": { "path": "$hashtags", "preserveNullAndEmptyArrays": true } }]'
)

expanded_hashtags = tweets$aggregate(
  '[
    { "$unwind": { "path": "$hashtags", "preserveNullAndEmptyArrays": true } },
    { $unwind: { path: "$symbols", preserveNullAndEmptyArrays: true } },
    { "$project": {
      "user_id": 1,
      "status_id": 1,  
      "hashtags": 1, 
      "created_at": 1, 
      "source": 1, 
      "is_quote": 1, 
      "is_retweet": 1
      }
    }
   ]'
)


df_source = tweets$aggregate(
'[
  {
    "$group": {
      "_id": "$source",
      "total": {
        "$sum": 1
      }
    }
  },
  {
    "$sort": {
      "total": -1
    }
  }
]'
)

names(df_source) <- c("source", "count")

ggplot(
  data=head(df_source, 10), 
  aes(x=reorder(source, -count), y=count)) +
  geom_bar(stat="identity", fill="steelblue") +
  xlab("Source") + ylab("Cantidad de tweets") +
  labs(title = "Cantidad de tweets en los principales clientes")

# Ejemplo usuarios
users <- mongo(
  collection = "users_mongo_covid19", 
  db = "DMUBA"
) 

df_users = users$find(
  query = '{}', 
  fields = '{
  "friends_count": true,
  "listed_count": true,
  "statuses_count": true,
  "favourites_count": true,
  "verified": true
}'
)
hist(df_users$friends_count, main="cantidad de amigos por usuarios")
hist(
  log10(df_users$friends_count  + 1), 
  main="Log10 - cantidad de amigos por usuarios"
)

boxplot(
  log10(df_users$friends_count  + 1)~verified,data=df_users, 
  main="Cantidad de amigos en cuentas verified vs no verified",
  ylab="Log de cantidad de amigos", 
  xlab="Verified Account"
  ) 