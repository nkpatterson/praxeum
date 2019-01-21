﻿using Newtonsoft.Json;

namespace Praxeum.FunctionApp.Data
{
    public class LearnerProgressStatus
    {
        [JsonProperty(PropertyName = "totalPoints")]
        public int TotalPoints { get; set; }

        [JsonProperty(PropertyName = "currentLevel")]
        public int  CurrentLevel { get; set; }

        [JsonProperty(PropertyName = "currentLevelPointsEarned")]
        public int CurrentLevelPointsEarned { get; set; }

        [JsonProperty(PropertyName = "badgesEarned")]
        public int BadgesEarned { get; set; }

        [JsonProperty(PropertyName = "trophiesEarned")]
        public int TrophiesEarned { get; set; }
    }
}
