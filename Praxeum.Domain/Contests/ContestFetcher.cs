﻿using System.Threading.Tasks;
using AutoMapper;
using Praxeum.Data;

namespace Praxeum.Domain.Contests
{
    public class ContestFetcher : IHandler<ContestFetch, ContestFetched>
    {
        private readonly IContestRepository _contestRepository;

        public ContestFetcher(
            IContestRepository contestRepository)
        {
            _contestRepository =
                contestRepository;
        }

        public async Task<ContestFetched> ExecuteAsync(
            ContestFetch contestFetch)
        {
            var contest =
                await _contestRepository.FetchByIdAsync(
                    contestFetch.Id);

            var contestFetched =
                Mapper.Map(contest, new ContestFetched());

            return contestFetched;
        }
    }
}