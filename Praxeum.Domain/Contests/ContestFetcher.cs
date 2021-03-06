﻿using System;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Praxeum.Data;

namespace Praxeum.Domain.Contests
{
    public class ContestFetcher : IHandler<ContestFetch, ContestFetched>
    {
        private readonly IMapper _mapper;
        private readonly IContestRepository _contestRepository;
        private readonly IContestLearnerRepository _contestLearnerRepository;

        public ContestFetcher(
            IMapper mapper,
            IContestRepository contestRepository,
            IContestLearnerRepository contestLearnerRepository)
        {
            _mapper =
                mapper;
            _contestRepository =
                contestRepository;
            _contestLearnerRepository =
                contestLearnerRepository;
        }

        public async Task<ContestFetched> ExecuteAsync(
            ContestFetch contestFetch)
        {
            var contest =
                await _contestRepository.FetchByIdAsync(
                    contestFetch.Id);

            if (contest == null)
            {
                throw new NullReferenceException($"Contest {contestFetch.Id} not found");
            }

            var contestFetched =
                _mapper.Map(contest, new ContestFetched());

            var contestLearners =
                await _contestLearnerRepository.FetchListAsync(
                    contestFetch.Id);

            contestLearners = 
                contestLearners.Where(
                    x => !string.IsNullOrWhiteSpace(x.DisplayName));

            _mapper.Map(contestLearners, contestFetched.Learners);

            return contestFetched;
        }
    }
}