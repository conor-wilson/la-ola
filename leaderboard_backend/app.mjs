import express from "express";
import { MongoClient } from "mongodb"
import cors from "cors";
import { env } from "cloudflare:workers";
import { httpServerHandler } from "cloudflare:node";
import { ulid } from "ulid";

const app = express();
const port = 3000;
const scoresDb = "leaderboards";
const scoresCollection = "scores";
const runsCollection = "runs";
const usersCollections = "users";

app.use(express.json());
app.use(cors());

function mongoCollection(database, collection) {
  const mongoClient = new MongoClient(env.MONGO_DB);
  const db = mongoClient.db(database);
  return db.collection(collection);
}

async function getScores(leaderboardId, userId) {
  const col = mongoCollection(scoresDb, scoresCollection);

  const query = { leaderboardId };
  if (userId) {
    query.userId = { $ne: userId };
  }

  const scores = await col.aggregate([
    {
      $match: query
    },
    {
      $lookup: {
        from: "users",
        localField: "userId",
        foreignField: "userId",
        as: "user"
      }
    },
    {
      $unwind: "$user"
    },
    {
      $project: {
        _id: 0,
        score: 1,
        name: "$user.name"
      }
    }
  ]).toArray();

  return scores;
}

function cleanScore(score) {
  score = parseInt(score);
  if (isNaN(score)) {
    score = 0;
  }
  return score;
}

function cleanName(name) {
  name = name.replace(/[^A-Za-z0-9 _-]/g, "");
  name = name.substring(0, 16);
  if (name == "") {
    const uid = ulid();
    name = "player_" + uid.substring(uid.length - 4).toLowerCase();
  }
  return name;
}

function badRequestError(msg) {
  const error = new Error(msg);
  error.errorCode = 400;
  return error;
}

async function setName(userId, name) {
  const col = mongoCollection(scoresDb, usersCollections);
  name = cleanName(name);
  //throw badRequestError("Setting names is disabled for now.");
  await col.updateOne({ userId }, { $set: { userId, name }}, { upsert: true });
  return name;
}

async function postScore(userId, leaderboardId, score) {
  const scoresCol = mongoCollection(scoresDb, scoresCollection);
  await scoresCol.updateOne({ userId, leaderboardId }, { $max: { score } }, { upsert: true });
}

async function startRun(userId, leaderboardId) {
  const runsCol = mongoCollection(scoresDb, runsCollection)
  const startTime = new Date();
  await runsCol.updateOne({ userId, leaderboardId, endTime: {$exists: false} }, { $set: { startTime }}, { upsert: true });
}

async function endRun(userId, leaderboardId) {
  const runsCol = mongoCollection(scoresDb, runsCollection)
  const endTime = new Date();
  await runsCol.updateOne({ userId, leaderboardId, startTime: { $exists: true }, endTime: { $exists: false } },
  [
    { $set: {
      endTime, 
      score,
      ip,
      duration: {
        $divide: [
          {
            $round: {
              $divide: [
                { $subtract: [endTime, "$startTime"] },
                100
              ]
            }
          },
          10
        ]
      }
    }}
  ]);
}

app.get('/', async (req, res) => {
  res.send("Ok");
})

app.get('/test', async (req, res) => {
  console.log(req.socket.remoteAddress)
  res.send();
})

app.post('/test', async (req, res) => {
  console.log(req.body)
  res.send();
})

app.post('/post_score', async (req, res) => {
  const data = req.body;
  const {userId, leaderboardId, score} = data;
  await postScore(userId, leaderboardId, score, ip);
  res.send();
})

app.post('/start_run', async (req, res) => {
  const data = req.body;
  const {userId, leaderboardId} = data;
  await startRun(userId, leaderboardId);
  res.send();
})

app.post('/end_run', async (req, res) => {
  const data = req.body;
  const {userId, leaderboardId, score} = data;
  const ip = req.socket.remoteAddress;
  await endRun(userId, leaderboardId, score, ip);
  res.send();
})

app.post('/set_name', async (req, res) => {
  const data = req.body;
  const {userId, name} = data;
  let savedName;
  try {
    savedName = await setName(userId, name);
  } catch (err) {
    console.log(err);
    res.status(err.errorCode).send(err.message);
    return;
  }
  res.send(savedName);
})

app.get('/get_scores/:leaderboardId', async (req, res) => {
  const userId = req.query.userId;
  const leaderboardId = req.params.leaderboardId;
  const scores = await getScores(leaderboardId, userId);
  res.send(JSON.stringify(scores));
})

app.listen(port, () => {
  console.log(`Listening on port ${port}`);
})

export default httpServerHandler({ port });
