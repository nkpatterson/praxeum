﻿using System.Threading.Tasks;

namespace Praxeum.Domain.Learners
{
    public class LearnerAdder : IHandler<LearnerAdd, LearnerAdded>
    {
        private readonly IEventPublisher _eventPublisher;

        public LearnerAdder(
            IEventPublisher eventPublisher)
        {
            _eventPublisher =
                eventPublisher;
        }

        public async Task<LearnerAdded> ExecuteAsync(
            LearnerAdd learnerAdd)
        {
            await _eventPublisher.PublishAsync("learner.add", learnerAdd);

            var learnerAdded =
                new LearnerAdded
                {
                    UserName = learnerAdd.Name,
                    Status = "Pending"
                };

            return learnerAdded;
        }
    }
}